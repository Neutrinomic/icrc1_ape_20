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

    stable var indexBlock = 4910;
    stable var processed = 0;
    stable var timercounter = 0;
    stable var totalMinted = 0;
    stable let accounts = Map.new<Principal, Nat64>();

    let ledger = actor ("ss2fx-dyaaa-aaaar-qacoq-cai") : Ledger.Self;

    let log = Vector.new<Text>();
    var stopped = true;

    public shared ({ caller }) func start() : async () {
        assert (caller == Principal.fromText("wgjuz-uw44a-ow3ml-e6ytr-b534d-7ie55-6snjg-62x6h-olo6a-jj5v3-eae"));
        stopped := false;
    };

    public shared ({ caller }) func stop() : async () {
        assert (caller == Principal.fromText("wgjuz-uw44a-ow3ml-e6ytr-b534d-7ie55-6snjg-62x6h-olo6a-jj5v3-eae"));
        stopped := true;
    };

    public shared ({ caller }) func go(t : Text) : async () {
        assert (Principal.toText(caller).size() > 35); // Ignore all canister calls so we don't allow frontrunning
        assert (stopped == false);

        let msg = Msg.Msg(t);

        ledger.icrc2_transfer_from({
            from = { owner = caller; subaccount = null };
            spender_subaccount = null;
            to = {
                owner = msg.getOwner();
                subaccount = ?msg.getSubaccount();
            };
            fee = null;
            memo = ?msg.getMemo();
            from_subaccount = null;
            created_at_time = null; // perhaps will be useful for ordering
            amount = 0;
        });

    };

    private func qtimer() : async () {
        if (stopped == false) {
            ignore Timer.setTimer(#seconds 60, qtimer);
            return;
        };
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

        if (rez.transactions.size() > 0) return Msg.fromBlock(rez.transactions[0]);

        let atx = rez.archived_transactions[0];
        let rezarc = await atx.callback({
            start = atx.start;
            length = atx.length;
        });

        Msg.fromBlock(rezarc.transactions[0]);
    };

    private func processtx(transactions : [Ledger.Transaction]) {
        for (t in transactions.vals()) {
            processed := processed + 1;
            switch (Msg.fromBlock(t)) {
                case (?(owner, msg)) {
                    if (msg == "🍌🍌🍌") balance_add(owner, 1);
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

    public query func stats() : async (Nat, Nat, Bool, Nat) {
        (processed, totalMinted, stopped, timercounter);
    };

    public query func getlog() : async [Text] {
        Vector.toArray(log);
    };

};
