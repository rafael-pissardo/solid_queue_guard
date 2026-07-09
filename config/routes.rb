# frozen_string_literal: true

SolidQueueGuard::Engine.routes.draw do
  get 'health', to: 'health#show'
end
