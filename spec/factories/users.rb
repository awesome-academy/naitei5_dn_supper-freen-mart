FactoryBot.define do
  factory :user do
    name {Faker::Name.name}
    email {Faker::Internet.email}
    password {"123456"}
    password_confirmation {"123456"}

    trait :activated do
      activated {true}
    end

    trait :admin do
      role {1}
    end

    factory :activated_user, class: User, traits: [:activated]
    factory :admin_user, class: User, traits: [:activated, :admin]
  end
end
