module CloudBabel
    class ApplicationController < ApplicationLesliController
        protect_from_forgery with: :exception
    end
end
