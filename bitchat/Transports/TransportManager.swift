//
//  TransportManager.swift
//  bitchat
//
//  This is free and unencumbered software released into the public domain.
//  For more information, see <https://unlicense.org>
//

import Foundation

class TransportManager {
    private var transports: [TransportProtocol] = []
    private var routingTable: [String: TransportType] = [:]
    
    weak var delegate: TransportDelegate?
    
    init() {
        // Initialize available transports
        let bluetoothTransport = BluetoothTransport()
        bluetoothTransport.setDelegate(self)
        transports.append(bluetoothTransport)
    }
    
    func startDiscovery() {
        for transport in transports {
            transport.startDiscovery()
        }
    }
    
    func stopDiscovery() {
        for transport in transports {
            transport.stopDiscovery()
        }
    }
    
    func send(_ packet: Data, to peer: String?) {
        // Simple routing for now: use the first available transport
        if let transport = transports.first(where: { $0.isAvailable }) {
            transport.send(packet, to: peer)
        }
    }
}

extension TransportManager: TransportDelegate {
    func didDiscoverPeer(_ peer: String) {
        delegate?.didDiscoverPeer(peer)
    }
    
    func didLosePeer(_ peer: String) {
        delegate?.didLosePeer(peer)
    }
    
    func didReceiveData(_ data: Data, from peer: String) {
        delegate?.didReceiveData(data, from: peer)
    }
}
