=begin

Lesli

Copyright (c) 2023, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

module LesliBabel
    class BucketsController < ApplicationController
        before_action :set_bucket, only: [:show, :edit, :update, :destroy]

        # GET /buckets
        def index
            respond_to do |format|
                format.html { }
                format.json { 
                    respond_with_successful(
                        Module.find(params[:module_id]).buckets.order(:code)
                    ) 
                }
            end
        end

        # GET /buckets/1
        def show
        end

        # GET /buckets/new
        def new
        @bucket = Bucket.new
        end

        # GET /buckets/1/edit
        def edit
        end

        # POST /buckets
        def create
            bucket = Bucket.new(bucket_params)
            bucket.module = Module.find(params[:module_id])
            bucket.reference_module = bucket.module.name

            if bucket.save
                respond_with_successful bucket
            else
                respond_with_error bucket.errors.full_messages
            end
        end

        # PATCH/PUT /buckets/1
        def update
        if @bucket.update(bucket_params)
        redirect_to @bucket, notice: 'Bucket was successfully updated.'
        else
        render :edit
        end
        end

        # DELETE /buckets/1
        def destroy
        @bucket.destroy
        redirect_to buckets_url, notice: 'Bucket was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_bucket
            @bucket = Bucket.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def bucket_params
            params.require(:bucket).permit(:name)
        end

    end
end
