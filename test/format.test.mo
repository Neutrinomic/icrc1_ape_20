import { test } "mo:test";
import F "../src/format";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";

test(
    "message - transfer",
    func() {
        let msg : F.Op = #transfer({
            to = Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai");
            amount = 2324;
        });
        let encoded = F.encode(msg);
        let ?decoded = F.decode(encoded) else Debug.trap("failed to decode");

        assert decoded == msg;
    },
);

test(
    "message - transfer big amount",
    func() {
        let msg : F.Op = #transfer({
            to = Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai");
            amount = 2324234234234234234;
        });
        let encoded = F.encode(msg);
        let ?decoded = F.decode(encoded) else Debug.trap("failed to decode");

        assert decoded == msg;
    },
);

test(
    "message - burn",
    func() {
        let msg : F.Op = #burn({
            amount = 23223334;
        });
        let encoded = F.encode(msg);
        let ?decoded = F.decode(encoded) else Debug.trap("failed to decode");

        assert decoded == msg;
    },
);
