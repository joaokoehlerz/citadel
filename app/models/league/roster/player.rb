class League
  class Roster
    class Player < ApplicationRecord
      belongs_to :roster
      belongs_to :user

      delegate :league, :division, to: :roster

      validate :unique_within_league
      validate :league_permissions, on: :create

      after_create do
        roster.transfers.create(user:, is_joining: true)
      end

      after_destroy do
        roster.transfers.create(user:, is_joining: false)
      end

      private

      def unique_within_league
        return if user.blank? || roster.blank?

        errors.add(:base, 'Can only be in one roster per league') if league.players.where(user:).where.not(id:).exists?
      end

      def league_permissions
        return if user.blank?

        errors.add(:base, 'User is banned from leagues') unless user.can?(:use, :leagues)
      end
    end
  end
end
