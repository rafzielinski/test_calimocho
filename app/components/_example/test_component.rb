# frozen_string_literal: true

# source: https://github.com/github/actionview-component

# EXAMPLE COMPONENT

# Usage in views:
# <%= render(Atoms::Test::TestComponent, title: "my title" ) do %>
# Hello, World!!!
# <% end %>

module Example # This allows you to use a folder structure
  class TestComponent < ActionView::Component::Base
    validates :content, :title, presence: true

    def initialize(title:)
      @title = title
    end

    private
      attr_reader :title
  end
end
