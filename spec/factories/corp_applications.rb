FactoryBot.define do
  factory :corp_application do
    user { nil }
    corporation { nil }
    application_text { "MyText" }
  end
end
