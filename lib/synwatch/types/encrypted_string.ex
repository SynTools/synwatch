defmodule Synwatch.Types.EncryptedString do
  use Cloak.Ecto.Binary, vault: Synwatch.Vault, type: :string
end
