//
//  TransportProtocol.swift
//  bitchat
//
//  This is free and unencumbered software released into the public domain.
//  For more information, see <https://unlicense.org>
//

import Foundation

protocol TransportProtocol {
    var transportType: TransportType { get }
    var isAvailable: Bool { get }
    
    func startDiscovery()
    func stopDiscovery()
    func send(_ packet: Data, to peer: String?)
    func setDelegate(_ delegate: TransportDelegate)
}

enum TransportType {
    case bluetooth
    case wifiDirect
    case ultrasonic
    case lora
}

protocol TransportDelegate: AnyObject {
    func didDiscoverPeer(_ peer: String)
    func didLosePeer(_ peer: String)
    func didReceiveData(_ data: Data, from peer: String)
}
