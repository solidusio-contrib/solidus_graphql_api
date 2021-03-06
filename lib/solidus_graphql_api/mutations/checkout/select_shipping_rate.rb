# frozen_string_literal: true

module SolidusGraphqlApi
  module Mutations
    module Checkout
      class SelectShippingRate < BaseMutation
        null true

        argument :shipping_rate_id, ID, required: true, loads: Types::ShippingRate

        field :order, Types::Order, null: true
        field :errors, [Types::UserError], null: false

        def resolve(shipping_rate:)
          current_order.update(state: :delivery)

          update_params = {
            shipments_attributes: {
              id: shipping_rate.shipment_id,
              selected_shipping_rate_id: shipping_rate.id
            }
          }

          if Spree::OrderUpdateAttributes.new(current_order, update_params).apply
            current_order.recalculate
            errors = []
          else
            errors = current_order.errors
          end

          { errors: user_errors('order', errors), order: current_order }
        end

        def ready?(*)
          current_ability.authorize!(:update, current_order, guest_token)
        end
      end
    end
  end
end
