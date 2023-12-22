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

actor {

    stable var indexBlock = 4681;
    stable var processed = 0;

    let ledger = actor("ss2fx-dyaaa-aaaar-qacoq-cai") : Ledger.Self;
    
    let log = Vector.new<Text>();
    var stopped = true;


    public shared({caller}) func start() : async () {
        assert(caller == Principal.fromText("wgjuz-uw44a-ow3ml-e6ytr-b534d-7ie55-6snjg-62x6h-olo6a-jj5v3-eae"));
        stopped := false;
    };

    public shared({caller}) func stop() : async () {
        assert(caller == Principal.fromText("wgjuz-uw44a-ow3ml-e6ytr-b534d-7ie55-6snjg-62x6h-olo6a-jj5v3-eae"));
        stopped := true;
    };

    public shared({caller}) func go(t:Text) : async () {
        let pp = Principal.toText(caller);
        assert(pp.size() > 35);  // Ignore all canister calls so we don't allow frontrunning
        assert(stopped == false);
       

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
            amount = 0
        });

    };

    // stable var chat = Vector.new<(Principal, Text)>();

    // private func qtimer() : async () {

    //     try {
    //         await proc();
    //     } catch (e) {
    //         Vector.add(log, Error.message(e));
    //     };
        
    //     ignore Timer.setTimer(#seconds 1, qtimer);
    // };

    // public func qq(id: Nat) : async ?(Principal, Text) {

    //     let rez = await ledger.get_transactions({
    //         start = id;
    //         length = 1;
    //     });

    //     Msg.fromBlock(rez.transactions[0]);
        
    // };

    // private func proc() : async () {
    //     let rez = await ledger.get_transactions({
    //         start = indexBlock;
    //         length = 100;
    //     });

    //     for (t in rez.transactions.vals()) {
    //         processed := processed + 1;
    //         switch (Msg.fromBlock(t)) {
    //             case (?b) {
    //                 Vector.add<(Principal,Text)>(chat, b);
    //             };
    //             case (null) ();
    //         };
    //     };

    //     indexBlock := indexBlock + rez.transactions.size();
    // };

    // ignore Timer.setTimer(#seconds 0, qtimer);

    // public query func getchat(idx:Nat) : async (Nat,[?(Principal, Text)]) {
    //     let size = Vector.size(chat);
    //     if (idx > size) {
    //         return (size,[]);
    //     };
        
    //     let how = Nat.min(100, size - idx);

    //     let rez = Array.tabulate<?(Principal, Text)>(how, func (i:Nat) = Vector.getOpt(chat, i));

    //     (size, rez);
    // };

    // public query func stats() : async Nat {
    //     processed;
    // };

    // public query func getlog() : async [Text] {
    //     Vector.toArray(log);
    // };


}