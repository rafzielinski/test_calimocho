# frozen_string_literal: true

class ApplicationComponent < ActionView::Component::Base
  def initialize(*)
    @slickr_nav_helper = Slickr::NavigationBuilder.new.nav_helper
    @slickr_settings = Slickr::Setting.get_all
  end
end
