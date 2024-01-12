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
    "message - transfer - self auth principal",
    func() {
        let msg : F.Op = #transfer({
            to = Principal.fromText("vwng4-j5dgs-e5kv2-ofyq2-hc4be-7u2fn-mmncn-u7dhj-nzkyq-vktfa-xqe");
            amount = 2324;
        });
        let encoded = F.encode(msg);
        let ?decoded = F.decode(encoded) else Debug.trap("failed to decode");

        assert decoded == msg;
    },
);

test(
    "message - transfer - system principal",
    func() {
        let msg : F.Op = #transfer({
            to = Principal.fromText("aaaaa-aa");
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


test(
    "message - deploy",
    func() {
        let msg : F.Op = #deploy({
            ticker = "GIG";
            name = "Giggles🍌";
        });
        let encoded = F.encode(msg);
        
        let ?decoded = F.decode(encoded) else Debug.trap("failed to decode");
        assert decoded == msg;
    },
);
