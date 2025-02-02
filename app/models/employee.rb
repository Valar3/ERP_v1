class Employee < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[github]
  has_many :given_kudos, class_name: 'Kudo', foreign_key: 'giver_id', dependent: :destroy,
                         inverse_of: :giver
  has_many :received_kudos, class_name: 'Kudo', foreign_key: 'receiver_id', dependent: :destroy,
                            inverse_of: :receiver
  has_many :orders, dependent: :destroy, inverse_of: :employee
  def password_required?
    false
  end
  validates :name, presence: true
  validates :surname, presence: true
  validates :password, presence: { on: :create, message: "can't be blank" }
  validates :street, presence: true
  validates :postcode, presence: true
  validates :city, presence: true

  def post_delivery?
    reward.delivery_method == 'post_delivery'
  end

  def online_delivery?
    reward.delivery_method == 'online'
  end

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |employee|
      employee.email = auth.info.email
      employee.password = Devise.friendly_token[0, 20]
      # user.name = auth.info.name   # assuming the user model has a name
      # user.image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      user.skip_confirmation!
    end
  end
end
