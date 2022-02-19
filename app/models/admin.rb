# frozen_string_literal: true

# Admin
class Admin < ApplicationRecord
  devise :database_authenticatable, :rememberable, :validatable, :registerable
end
