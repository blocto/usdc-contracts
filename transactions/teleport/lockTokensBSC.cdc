import FungibleToken from "../../contracts/flow/token/FungibleToken.cdc"
import FiatToken from "../../contracts/flow/token/FiatToken.cdc"
import TeleportCustodyBSC from "../../contracts/flow/teleport/TeleportCustodyBSC.cdc"

transaction(admin: Address, amount: UFix64, target: String) {

    // The TeleportUser reference for teleport operations
    let teleportUserRef: &TeleportCustodyBSC.TeleportAdmin{TeleportCustodyBSC.TeleportUser}

    // The Vault resource that holds the tokens that are being transferred
    let sentVault: @FungibleToken.Vault

    prepare(signer: AuthAccount) {
        self.teleportUserRef = getAccount(admin).getCapability(TeleportCustodyBSC.TeleportAdminTeleportUserPath)
            .borrow<&TeleportCustodyBSC.TeleportAdmin{TeleportCustodyBSC.TeleportUser}>()
            ?? panic("Could not borrow a reference to TeleportOut")

        let vaultRef = signer.borrow<&FiatToken.Vault>(from: FiatToken.VaultStoragePath)
            ?? panic("Could not borrow a reference to the vault resource")

        self.sentVault <- vaultRef.withdraw(amount: amount)
    }

    execute {
        self.teleportUserRef.lock(from: <- self.sentVault, to: target.decodeHex())
    }
}
