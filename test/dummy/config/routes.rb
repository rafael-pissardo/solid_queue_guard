# frozen_string_literal: true

Rails.application.routes.draw do
  mount SolidQueueGuard::Engine, at: "/solid_queue_guard"
end
