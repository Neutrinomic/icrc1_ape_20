import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import I "mo:itertools/Iter";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Debug "mo:base/Debug";

module {

    // This file is just unused protocol draft

    public type Token = Nat32;

    public type Op = {
        #transfer : {
            to : Principal;
            amount : Nat64;
        };
        #burn : {
            amount : Nat64;
        };
        #mint;
    };

    private func EPrincipal(x : Principal) : [Nat8] {
        let pa = Blob.toArray(Principal.toBlob(x));
        let pasize : Nat8 = Nat8.fromNat(pa.size());
        let merged = I.flattenArray<Nat8>([[pasize], pa]);
        Iter.toArray(I.pad(merged, 30, 0 : Nat8));
    };

    private func DPrincipal(x : [Nat8]) : Principal {
        let size = Nat8.toNat(x[0]);
        let blob = Blob.fromArray(Array.subArray(x, 1, size));
        Principal.fromBlob(blob);
    };

    private func ENat64(value : Nat64) : [Nat8] {
        return [
            Nat8.fromNat(Nat64.toNat(value >> 56)),
            Nat8.fromNat(Nat64.toNat((value >> 48) & 255)),
            Nat8.fromNat(Nat64.toNat((value >> 40) & 255)),
            Nat8.fromNat(Nat64.toNat((value >> 32) & 255)),
            Nat8.fromNat(Nat64.toNat((value >> 24) & 255)),
            Nat8.fromNat(Nat64.toNat((value >> 16) & 255)),
            Nat8.fromNat(Nat64.toNat((value >> 8) & 255)),
            Nat8.fromNat(Nat64.toNat(value & 255)),
        ];
    };

    private func DNat64(array : [Nat8]) : Nat64 {
        assert (array.size() == 8);

        return Nat64.fromNat(Nat8.toNat(array[0])) << 56 | Nat64.fromNat(Nat8.toNat(array[1])) << 48 | Nat64.fromNat(Nat8.toNat(array[2])) << 40 | Nat64.fromNat(Nat8.toNat(array[3])) << 32 | Nat64.fromNat(Nat8.toNat(array[4])) << 24 | Nat64.fromNat(Nat8.toNat(array[5])) << 16 | Nat64.fromNat(Nat8.toNat(array[6])) << 8 | Nat64.fromNat(Nat8.toNat(array[7]));
    };

    public func encode(op : Op) : [Nat8] {
        switch (op) {
            case (#transfer({ to; amount })) Iter.toArray(I.flattenArray([[0 : Nat8], EPrincipal(to), ENat64(amount)]));
            case (#burn({ amount })) Iter.toArray(I.flattenArray([[1 : Nat8], ENat64(amount)]));
            case (#mint)[2];
            case (_)[];
        };
    };

    public func decode(b : [Nat8]) : ?Op {
        switch (b[0]) {
            case (0) {
                ? #transfer({
                    to = DPrincipal(Array.subArray(b, 1, 30));
                    amount = DNat64(Array.subArray(b, 31, 8));
                });
            };
            case (1) {
                ? #burn({
                    amount = DNat64(Array.subArray(b, 1, 8));
                });
            };
            case (2) {
                ? #mint;
            };
            case (_) null;
        };
    };

};
