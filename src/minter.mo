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

    // Configurable
    let ledger = actor ("ss2fx-dyaaa-aaaar-qacoq-cai") : Ledger.Self;

    let log = Vector.new<Text>();
    var stopped = true;

    public shared ({ caller }) func start() : async () {
        assert Principal.isController(caller);
        stopped := false;
    };

    public shared ({ caller }) func stop() : async () {
        assert Principal.isController(caller);
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

    public query func hasStopped() : async Bool {
        stopped;
    };

};
