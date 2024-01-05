import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Ledger "./ledger";
import Text "mo:base/Text";
import Nat8 "mo:base/Nat8";

module {

    let prefix : [Nat8] = [100, 101, 2]; // 2 at the end is fixed

    public class Msg(buf : [Nat8]) {

        let bsize = buf.size();

        assert (bsize < 137);

        let ba = Array.tabulate<Nat8>(160, func(i) = if (i < bsize) buf[i] else 0);

        public func getOwner() : Principal {
            Principal.fromBlob(Blob.fromArray(Array.append<Nat8>(Array.subArray(ba, 0, 26), prefix)));
        };

        public func getSubaccount() : Blob {
            Blob.fromArray(Array.append<Nat8>([Nat8.fromNat(bsize)], Array.subArray(ba, 26, 31)));
        };

        public func getMemo() : Blob {
            Blob.fromArray(Array.subArray(ba, 57, 80));
        };
    };

    public func fromBlock(minter : Principal, c : Ledger.Transaction) : ?(Principal, [Nat8]) {
        let ?transfer = c.transfer else return null;
        let ?memo = transfer.memo else return null;
        let ?subaccount = transfer.to.subaccount else return null;
        let ?spender = transfer.spender else return null;
        if (spender.owner != minter) return null;

        let prb = Blob.toArray(Principal.toBlob(transfer.to.owner));
        // protocol prefix
        if (prb.size() < 28) return null;
        let code = Array.subArray(prb, 26, 3);
        if (code != prefix) return null;

        // principal
        let pb = Array.subArray(prb, 0, 26);

        // memo
        let bm : [Nat8] = Blob.toArray(memo);

        // subaccount
        let sa = Blob.toArray(subaccount);
        if (sa.size() < 32) return null;
        let ta = Array.subArray(sa, 0, 1);
        let msgsize = Nat8.toNat(ta[0]);
        let sa2 = Array.subArray(sa, 1, 31);
        let fin = Array.append<Nat8>(Array.append<Nat8>(pb, sa2), bm);
        if (fin.size() < msgsize) return null;
        let f2 = Array.subArray<Nat8>(fin, 0, msgsize);

        ?(transfer.from.owner, f2);
    };

};
