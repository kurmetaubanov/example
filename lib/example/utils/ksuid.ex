defmodule Example.Utils.Ksuid do
  # well this module could be temporary here
  @epoch 1400000000
  @alphabet "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

  def generate(prefix \\ "") do
    timestamp = :os.system_time(:second) - @epoch
    payload = :crypto.strong_rand_bytes(16)
    ksuid = encode_base62(timestamp, payload)
    "#{prefix}_#{ksuid}"
  end

  defp encode_base62(timestamp, payload) do
    full_binary = <<timestamp::big-integer-size(32), payload::binary>>
    num = :binary.decode_unsigned(full_binary, :big)
    do_encode_base62(num, "")
  end

  defp do_encode_base62(0, acc), do: acc
  defp do_encode_base62(num, acc) do
    div = div(num, 62)
    rem = rem(num, 62)
    do_encode_base62(div, <<String.slice(@alphabet, rem, 1)::binary, acc::binary>>)
  end

end
