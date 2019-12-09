Rails.application.routes.draw do
  mount CloudBabel::Engine => "/cloud_babel"
end
