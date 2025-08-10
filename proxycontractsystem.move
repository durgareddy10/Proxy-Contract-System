module durga_addr::ProxySystem {
    use std::signer;
    use std::vector;
    use std::string::String;
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::account;
    use aptos_framework::timestamp;

    
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_INVALID_VERSION: u64 = 2;
    const E_PROXY_NOT_FOUND: u64 = 3;
    const E_IMPLEMENTATION_NOT_SET: u64 = 4;

    struct ProxyContract has key {
        implementation_address: address,
        version: u64,
        admin: address,
        initialized: bool,
        upgrade_events: EventHandle<UpgradeEvent>,
    }

    struct ImplementationRegistry has key {
        implementations: vector<ImplementationInfo>,
        admin: address,
    }

    struct ImplementationInfo has store, copy, drop {
        address: address,
        version: u64,
        name: String,
        created_at: u64,
    }

    struct UpgradeEvent has drop, store {
        old_implementation: address,
        new_implementation: address,
        version: u64,
        timestamp: u64,
    }

    struct ProxyState has key {
        proxies: vector<address>,
        next_proxy_id: u64,
    }

    public entry fun initialize(admin: &signer) {
        let admin_addr = signer::address_of(admin);
       
        move_to(admin, ImplementationRegistry {
            implementations: vector::empty<ImplementationInfo>(),
            admin: admin_addr,
        });

      
        move_to(admin, ProxyState {
            proxies: vector::empty<address>(),
            next_proxy_id: 0,
        });
    }

    public entry fun create_proxy(
        admin: &signer,
        initial_implementation: address,
        version: u64,
    ) acquires ProxyState {
        let admin_addr = signer::address_of(admin);
        
      
        let proxy = ProxyContract {
            implementation_address: initial_implementation,
            version,
            admin: admin_addr,
            initialized: true,
            upgrade_events: account::new_event_handle<UpgradeEvent>(admin),
        };

        move_to(admin, proxy);

        let proxy_state = borrow_global_mut<ProxyState>(admin_addr);
        vector::push_back(&mut proxy_state.proxies, admin_addr);
        proxy_state.next_proxy_id = proxy_state.next_proxy_id + 1;
    }


    public entry fun register_implementation(
        admin: &signer,
        implementation_addr: address,
        version: u64,
        name: String,
    ) acquires ImplementationRegistry {
        let admin_addr = signer::address_of(admin);
        let registry = borrow_global_mut<ImplementationRegistry>(admin_addr);
        
        assert!(registry.admin == admin_addr, E_NOT_AUTHORIZED);

        let impl_info = ImplementationInfo {
            address: implementation_addr,
            version,
            name,
            created_at: timestamp::now_seconds(),
        };

        vector::push_back(&mut registry.implementations, impl_info);
    }

   
    public entry fun upgrade_proxy(
        admin: &signer,
        proxy_addr: address,
        new_implementation: address,
        new_version: u64,
    ) acquires ProxyContract {
        let admin_addr = signer::address_of(admin);
        let proxy = borrow_global_mut<ProxyContract>(proxy_addr);
        
        assert!(proxy.admin == admin_addr, E_NOT_AUTHORIZED);
        assert!(new_version > proxy.version, E_INVALID_VERSION);

        let old_implementation = proxy.implementation_address;
        proxy.implementation_address = new_implementation;
        proxy.version = new_version;

        event::emit_event(&mut proxy.upgrade_events, UpgradeEvent {
            old_implementation,
            new_implementation,
            version: new_version,
            timestamp: timestamp::now_seconds(),
        });
    }

    public fun get_implementation(proxy_addr: address): address acquires ProxyContract {
        let proxy = borrow_global<ProxyContract>(proxy_addr);
        proxy.implementation_address
    }

    public fun get_version(proxy_addr: address): u64 acquires ProxyContract {
        let proxy = borrow_global<ProxyContract>(proxy_addr);
        proxy.version
    }

    public fun get_admin(proxy_addr: address): address acquires ProxyContract {
        let proxy = borrow_global<ProxyContract>(proxy_addr);
        proxy.admin
    }

    public fun is_initialized(proxy_addr: address): bool acquires ProxyContract {
        if (!exists<ProxyContract>(proxy_addr)) {
            return false
        };
        let proxy = borrow_global<ProxyContract>(proxy_addr);
        proxy.initialized
    }
    
    public fun get_implementations(registry_addr: address): vector<ImplementationInfo> acquires ImplementationRegistry {
        let registry = borrow_global<ImplementationRegistry>(registry_addr);
        registry.implementations
    }

    public fun get_all_proxies(admin_addr: address): vector<address> acquires ProxyState {
        let proxy_state = borrow_global<ProxyState>(admin_addr);
        proxy_state.proxies
    }

  
    public entry fun transfer_admin(
        current_admin: &signer,
        proxy_addr: address,
        new_admin: address,
    ) acquires ProxyContract {
        let admin_addr = signer::address_of(current_admin);
        let proxy = borrow_global_mut<ProxyContract>(proxy_addr);
        
        assert!(proxy.admin == admin_addr, E_NOT_AUTHORIZED);
        proxy.admin = new_admin;
    }

    public entry fun set_proxy_state(
        admin: &signer,
        proxy_addr: address,
        active: bool,
    ) acquires ProxyContract {
        let admin_addr = signer::address_of(admin);
        let proxy = borrow_global_mut<ProxyContract>(proxy_addr);
        
        assert!(proxy.admin == admin_addr, E_NOT_AUTHORIZED);
        proxy.initialized = active;
    }

    #[view]
 
    public fun view_implementation_info(proxy_addr: address): (address, u64, address, bool) acquires ProxyContract {
        let proxy = borrow_global<ProxyContract>(proxy_addr);
        (proxy.implementation_address, proxy.version, proxy.admin, proxy.initialized)
    }

    #[view]
    public fun implementation_exists(registry_addr: address, impl_addr: address): bool acquires ImplementationRegistry {
        let registry = borrow_global<ImplementationRegistry>(registry_addr);
        let implementations = &registry.implementations;
        let len = vector::length(implementations);
        let i = 0;
        
        while (i < len) {
            let impl_info = vector::borrow(implementations, i);
            if (impl_info.address == impl_addr) {
                return true
            };
            i = i + 1;
        };
        false
    }

}
