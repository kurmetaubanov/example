defimpl Jason.Encoder, for: Regex do
  # this will fix Ash GraphQL's error management for Regex typed validations
  def encode(%Regex{source: source}, opts) do
    Jason.Encode.string(source, opts)
  end
end
