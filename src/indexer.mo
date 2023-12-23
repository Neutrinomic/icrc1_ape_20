import Ledger "./ledger";
import Msg "./msg";
import Nat8 "mo:base/Nat8";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Vector "mo:vector";
import Timer "mo:base/Timer";
import Error "mo:base/Error";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Map "mo:map/Map";
import Option "mo:base/Option";
import { phash } "mo:map/Map";
import Nat64 "mo:base/Nat64";
import I "mo:itertools/Iter";
import Iter "mo:base/Iter";

actor {

    stable var indexBlock = 4910; // start from block
    stable var processed = 0;
    stable var timercounter = 0;
    stable var totalMinted = 0;
    stable let accounts = Map.new<Principal, Nat64>();

    // Configurable
    let minter = Principal.fromText("bqzgt-iiaaa-aaaai-qpdoa-cai");
    let ledger = actor ("ss2fx-dyaaa-aaaar-qacoq-cai") : Ledger.Self;
    let mintMsg = "🍌🍌🍌";

    let log = Vector.new<Text>();

    private func qtimer() : async () {
        timercounter := timercounter + 1;
        try {
            await proc();
        } catch (e) {
            Vector.add(log, Error.message(e));
        };

        ignore Timer.setTimer(#seconds 0, qtimer);
    };

    public func decode_block(id : Nat) : async ?(Principal, Text) {

        let rez = await ledger.get_transactions({
            start = id;
            length = 1;
        });

        if (rez.transactions.size() > 0) return Msg.fromBlock(minter, rez.transactions[0]);

        let atx = rez.archived_transactions[0];
        let rezarc = await atx.callback({
            start = atx.start;
            length = atx.length;
        });

        Msg.fromBlock(minter, rezarc.transactions[0]);
    };

    private func processtx(transactions : [Ledger.Transaction]) {
        for (t in transactions.vals()) {
            processed := processed + 1;
            switch (Msg.fromBlock(minter, t)) {
                case (?(owner, msg)) {
                    if (msg == mintMsg) balance_add(owner, 1);
                };
                case (null)();
            };
        };
    };

    public func export(from : ?Principal) : async [(Principal, Nat64)] {
        let it = Map.entriesFrom(accounts, phash, from);
        let limited = I.take(it, 100);
        Iter.toArray(limited);
    };

    private func proc() : async () {
        let rez = await ledger.get_transactions({
            start = indexBlock;
            length = 1000;
        });

        processtx(rez.transactions);

        indexBlock := indexBlock + rez.transactions.size();

        for (atx in rez.archived_transactions.vals()) {
            let txresp = await atx.callback({
                start = atx.start;
                length = atx.length;
            });
            processtx(txresp.transactions);

            indexBlock := indexBlock + txresp.transactions.size();
        };
    };

    private func balance_add(to : Principal, amount : Nat64) : () {
        let balance = Option.get(Map.get(accounts, phash, to), 0 : Nat64);
        Map.set(accounts, phash, to, balance + amount);
        totalMinted := totalMinted + Nat64.toNat(amount);
    };

    ignore Timer.setTimer(#seconds 0, qtimer);

    public query func balance_of(p : Principal) : async Nat64 {
        Option.get(Map.get(accounts, phash, p), 0 : Nat64);
    };

    public query func stats() : async (Nat, Nat, Nat) {
        (processed, totalMinted, timercounter);
    };

    public query func getlog() : async [Text] {
        Vector.toArray(log);
    };

};
