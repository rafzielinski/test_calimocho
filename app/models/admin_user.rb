# frozen_string_literal: true

class AdminUser < ApplicationRecord
  include Slickr::SlickrAdminUser
  ROLES = [:admin, :editor, :author, :contributor]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
end
