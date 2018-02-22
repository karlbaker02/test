# Shared methods for controllers which use the journey hint cookie to give users IDP suggestions
module JourneyHintingPartialController
  def journey_hint_value
    MultiJson.load(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] ||= '')
  rescue MultiJson::ParseError
    nil
  end

  def retrieve_decorated_singleton_idp_array_by_entity_id(providers, entity_id)
    IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(providers.select { |idp| idp.entity_id == entity_id })
  end
end
