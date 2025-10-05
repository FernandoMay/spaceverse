// lib/core/blockchain/ethereum_address.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:spaceverse/exceptions.dart';
import 'package:web3dart/web3dart.dart';
// import 'package:spaceverse/core/errors/exceptions.dart';

class EthereumAddress {
  final String address;
  
  EthereumAddress(this.address) {
    if (!_isValidAddress(address)) {
      throw BlockchainException('Invalid Ethereum address');
    }
  }
  
  factory EthereumAddress.fromHex(String hex) {
    if (!hex.startsWith('0x')) {
      hex = '0x$hex';
    }
    return EthereumAddress(hex);
  }
  
  factory EthereumAddress.fromPublicKey(Uint8List publicKey) {
    // Remove the first byte (0x04 for uncompressed keys)
    final publicKeyNoPrefix = publicKey.sublist(1);
    
    // Hash the public key with Keccak-256
    final hash = keccak256(publicKeyNoPrefix);
    
    // Take the last 20 bytes
    final addressBytes = hash.sublist(12);
    
    // Convert to hex
    final hexAddress = '0x${_bytesToHex(addressBytes)}';
    
    // Apply checksum
    return EthereumAddress(_toChecksumAddress(hexAddress));
  }
  
  static bool _isValidAddress(String address) {
    if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(address)) {
      return false;
    }
    
    // Check checksum if mixed case
    if (address != address.toLowerCase() && address != address.toUpperCase()) {
      return address == _toChecksumAddress(address);
    }
    
    return true;
  }
  
  static String _toChecksumAddress(String address) {
    address = address.toLowerCase().substring(2);
    
    final hash = keccak256(utf8.encode(address));
    final hashHex = _bytesToHex(hash);
    
    String checksumAddress = '0x';
    for (int i = 0; i < address.length; i++) {
      final hashInt = int.parse(hashHex[i], radix: 16);
      if (hashInt >= 8) {
        checksumAddress += address[i].toUpperCase();
      } else {
        checksumAddress += address[i];
      }
    }
    
    return checksumAddress;
  }
  
  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
  
  Uint8List toBytes() {
    final hex = address.substring(2);
    return Uint8List.fromList(
      List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16))
    );
  }
  
  @override
  String toString() => address;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EthereumAddress && other.address.toLowerCase() == address.toLowerCase();
  }
  
  @override
  int get hashCode => address.toLowerCase().hashCode;
}