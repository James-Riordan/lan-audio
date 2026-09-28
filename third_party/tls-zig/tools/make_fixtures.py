"""Generate public, disposable test credentials; qualified with cryptography 48.0.0.

Keys are intentionally committed fixtures. Never use them outside local tests.
"""
from pathlib import Path
from datetime import datetime, timezone
import ipaddress
from cryptography import x509
from cryptography.x509.oid import NameOID, ExtendedKeyUsageOID
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec

OUT = Path(__file__).resolve().parents[1] / "tests" / "fixtures"
OUT.mkdir(exist_ok=True)
START = datetime(2025, 1, 1, tzinfo=timezone.utc)
END = datetime(2030, 1, 1, tzinfo=timezone.utc)

def issue(name, issuer=None, ca=False, expired=False, client=False):
    key = ec.generate_private_key(ec.SECP256R1())
    subject = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, name)])
    issuer_cert, issuer_key = issuer if issuer else (None, key)
    b = (x509.CertificateBuilder().subject_name(subject)
         .issuer_name(issuer_cert.subject if issuer else subject)
         .public_key(key.public_key()).serial_number(x509.random_serial_number())
         .not_valid_before(START)
         .not_valid_after(datetime(2025, 2, 1, tzinfo=timezone.utc) if expired else END)
         .add_extension(x509.BasicConstraints(ca=ca, path_length=0 if ca else None), True)
         .add_extension(x509.KeyUsage(True, False, False, False, False, ca, ca, None, None), True)
         .add_extension(x509.SubjectKeyIdentifier.from_public_key(key.public_key()), False)
         .add_extension(x509.AuthorityKeyIdentifier.from_issuer_public_key(issuer_key.public_key()), False))
    if not ca:
        b = b.add_extension(x509.ExtendedKeyUsage([ExtendedKeyUsageOID.CLIENT_AUTH if client else ExtendedKeyUsageOID.SERVER_AUTH]), False)
        b = b.add_extension(x509.SubjectAlternativeName([x509.DNSName("localhost"), x509.IPAddress(ipaddress.ip_address("127.0.0.1"))]), False)
    cert = b.sign(issuer_key, hashes.SHA256())
    (OUT / f"{name}.pem").write_bytes(cert.public_bytes(serialization.Encoding.PEM))
    if not ca:
        (OUT / f"{name}.key").write_bytes(key.private_bytes(serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8, serialization.NoEncryption()))
    return cert, key

ca = issue("ca", ca=True)
issue("other-ca", ca=True)
issue("server", ca)
issue("expired", ca, expired=True)
issue("client", ca, client=True)
issue("wrong-purpose", ca, client=True)
print(f"Wrote disposable fixtures to {OUT}")
