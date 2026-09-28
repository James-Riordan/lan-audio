"""Check that infrastructure failure cannot masquerade as caught ABI corruption."""
import importlib.util
from pathlib import Path
import sys
import unittest

tools = Path(__file__).resolve().parents[1] / 'tools'
sys.path.insert(0, str(tools))
spec = importlib.util.spec_from_file_location('miniaudio_abi_runner', tools / 'test_abi.py')
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


class EvidenceClassification(unittest.TestCase):
    def test_positive_requires_executed_test_count(self):
        self.assertTrue(runner.classify(0, '8/8 tests passed'))
        self.assertFalse(runner.classify(0, 'run test cached'))
        self.assertFalse(runner.classify(1, '8/8 tests passed'))

    def test_consumer_requires_its_own_count(self):
        self.assertTrue(runner.classify(0, '1/1 tests passed', consumer=True))
        self.assertFalse(runner.classify(0, '8/8 tests passed', consumer=True))

    def test_size_fault_requires_runtime_witness(self):
        witness = ("error: 'abi.test.C and Zig object sizes and alignments agree' failed:\n"
                   'ABI size ma_device: Zig=1 C=2\nTestExpectedEqual\n4/5 tests passed (1 failed)')
        self.assertTrue(runner.classify(1, witness, 'size'))
        self.assertFalse(runner.classify(0, witness, 'size'))
        self.assertFalse(runner.classify(None, witness, 'size'))
        self.assertFalse(runner.classify(-9, witness, 'size'))
        self.assertFalse(runner.classify(1, 'C compiler not found', 'size'))
        self.assertFalse(runner.classify(1, '4/5 tests passed (1 failed)', 'size'))

    def test_profile_fault_requires_size_and_offset_witnesses(self):
        witness = ("error: 'abi.test.C and Zig object sizes and alignments agree' failed:\n"
                   'ABI size ma_device: Zig=1 C=2\nABI size ma_device_info: Zig=3 C=4\n'
                   "error: 'abi.test.C and Zig callback userdata and endpoint field offsets agree' failed:\n"
                   'ABI offset #10 isDefault: Zig=5 C=6\nTestExpectedEqual\n3/5 tests passed (2 failed)')
        self.assertTrue(runner.classify(1, witness, 'profile'))
        self.assertFalse(runner.classify(1, witness.replace('ABI offset #10 isDefault:', 'missing'), 'profile'))
        self.assertFalse(runner.classify(1, 'linker failure', 'profile'))

    def test_optimized_assertion_needs_no_debug_stack_trace(self):
        witness = ("error: 'abi.test.C and Zig object sizes and alignments agree' failed:\n"
                   'ABI size ma_device: Zig=3312 C=3313\nexpected 0, found 1\n'
                   'Build Summary: 4/6 steps succeeded (1 failed); 4/5 tests passed (1 failed)')
        self.assertTrue(runner.classify(1, witness, 'size'))
        self.assertFalse(runner.classify(1, witness.replace("'abi.test.C and Zig object sizes and alignments agree'", "'unrelated'"), 'size'))

    def test_unknown_fault_is_not_accepted(self):
        self.assertFalse(runner.classify(1, 'failure', 'unrecognized'))


if __name__ == '__main__':
    unittest.main()
