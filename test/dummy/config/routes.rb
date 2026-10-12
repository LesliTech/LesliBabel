Rails.application.routes.draw do
    mount Lesli::Engine => "/lesli"
    mount LesliBabel::Engine => "/babel"
end
