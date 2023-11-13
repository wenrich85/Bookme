defmodule Bookme.Impl.Location do
  defstruct ~w[location_id customer_id street1 street2 city state zip description]a

  def new(%{customer_id: customer_id, street1: street1, street2: street2, city: city, state: state, zip: zip, description: description}) do
    %__MODULE__{
      location_id: generate_id(zip, customer_id),
      customer_id: customer_id,
      street1: street1,
      street2: street2,
      city: city,
      state: state,
      zip: zip,
      description: description
    }
  end

  defp generate_id(zip,customer_id), do:
      "#{Integer.to_string(zip)}-#{customer_id}-#{Integer.to_string(Enum.random(1000..100000))}"



end
