import { test } "mo:test";
import F "../src/format";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";

test(
    "simple test",
    func() {
        Debug.print(debug_show (F.encode(#transfer({ to = Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai"); amount = 2324 }))));
        assert true;
    },
);
