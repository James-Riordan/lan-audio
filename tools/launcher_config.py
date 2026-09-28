"""Resolve one declarative launcher document without writes or host side effects.

Common settings merge with the detected target's layer. Audio overrides affect
only the transient home session, never saved identity or user profile files.
"""
import ipaddress
from pathlib import Path

from setup_desktop import read_json, TARGET_FILES

LAYER_FIELDS = {'state_directory', 'receiver_address', 'audio'}
AUDIO_FIELDS = {'device', 'buffer_ms', 'max_buffer_ms', 'reconnect'}


def validate_layer(layer):
    if not isinstance(layer, dict) or set(layer)-LAYER_FIELDS:
        raise ValueError('launcher layer allows only state_directory, receiver_address and audio')
    if 'state_directory' in layer and (not isinstance(layer['state_directory'], str) or not layer['state_directory'].strip() or '\0' in layer['state_directory']):
        raise ValueError('state_directory must be a nonempty path string')
    if 'receiver_address' in layer:
        if not isinstance(layer['receiver_address'], str):
            raise ValueError('receiver_address must be a numeric IPv4 string')
        address = ipaddress.IPv4Address(layer['receiver_address'])
        if address.is_unspecified or address.is_multicast or str(address) == '255.255.255.255':
            raise ValueError('receiver_address must identify one receiver')
    if 'audio' not in layer:
        return
    audio = layer['audio']
    if not isinstance(audio, dict) or set(audio)-AUDIO_FIELDS:
        raise ValueError('audio allows only device, buffer_ms, max_buffer_ms and reconnect')
    for field in ('buffer_ms', 'max_buffer_ms'):
        if field in audio and (type(audio[field]) is not int or not 5 <= audio[field] <= 240):
            raise ValueError(field+' must be an integer from 5 to 240 milliseconds')
    if 'device' in audio and (not isinstance(audio['device'], str) or not audio['device'] or '\0' in audio['device'] or len(audio['device'].encode('utf-8'))>1024):
        raise ValueError('device must be a nonempty device name of at most 1024 UTF-8 bytes')
    if 'reconnect' in audio and type(audio['reconnect']) is not bool:
        raise ValueError('reconnect must be true or false')


def resolve(path, target):
    """Validate every environment, so a typo cannot lurk until switching devices."""
    if target not in TARGET_FILES:
        raise ValueError('unsupported launcher target')
    value = read_json(path)
    if type(value.get('schema')) is not int or value['schema'] != 1 or set(value)-LAYER_FIELDS-{'schema','environments'}:
        raise ValueError('invalid launcher schema; expected schema 1 and known settings')
    common = {name:value[name] for name in LAYER_FIELDS if name in value}
    validate_layer(common)
    environments = value.get('environments', {})
    if not isinstance(environments, dict) or set(environments)-set(TARGET_FILES):
        raise ValueError('environments allows windows-x86_64 and macos-x86_64')
    for layer in environments.values():
        validate_layer(layer)
    for layer in [{}, *environments.values()]:
        merged_audio = {**common.get('audio', {}), **layer.get('audio', {})}
        if 'buffer_ms' in merged_audio and 'max_buffer_ms' in merged_audio and merged_audio['buffer_ms']>merged_audio['max_buffer_ms']:
            raise ValueError('buffer_ms must not exceed max_buffer_ms in any environment')
    selected = environments.get(target, {})
    result = {**common, **selected}
    result['audio'] = {**common.get('audio', {}), **selected.get('audio', {})}
    if 'state_directory' in result:
        result['state_directory'] = (Path(path).resolve().parent/result['state_directory']).resolve()
    return result
