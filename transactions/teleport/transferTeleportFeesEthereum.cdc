import FungibleToken from "../../contracts/flow/token/FungibleToken.cdc"
import FiatToken from "../../contracts/flow/token/FiatToken.cdc"
import TeleportCustodyEthereum from "../../contracts/flow/teleport/TeleportCustodyEthereum.cdc"

transaction(target: Address) {
  // The teleport admin reference
  let teleportAdminRef: &TeleportCustodyEthereum.TeleportAdmin

  prepare(teleportAdmin: AuthAccount) {
    self.teleportAdminRef = teleportAdmin.borrow<&TeleportCustodyEthereum.TeleportAdmin>(from: TeleportCustodyEthereum.TeleportAdminStoragePath)
        ?? panic("Could not borrow a reference to the teleport admin resource")
  }

  execute {
    let feeVault <- self.teleportAdminRef.withdrawFee(amount: self.teleportAdminRef.getFeeAmount())

    // Get the recipient's public account object
    let recipient = getAccount(target)

    // Get a reference to the recipient's Receiver
    let receiverRef = recipient.getCapability(FiatToken.VaultReceiverPubPath)
      .borrow<&{FungibleToken.Receiver}>()
      ?? panic("Could not borrow receiver reference to the recipient's Vault")

    // Deposit the withdrawn tokens in the recipient's receiver
    receiverRef.deposit(from: <- feeVault)
  }
}
