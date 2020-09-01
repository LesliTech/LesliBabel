<script>
/*
Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/



// · import components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentStringEditor from "../components/string-editor.vue"


// · 
export default {
    components: {
        "component-string-editor": componentStringEditor
    },
    props: {
        bucket: {

        },
        module: {

        }
    },
    data() {
        return {
            label: "",
            labelPrefix: "",
            prefixes: [
                'mailer',
                'column',
                'column_enum',

                'view',
                'view_title',

                'view_toolbar_filter',
                'view_toolbar_filter_placeholder',
                'view_toolbar_search_by_placeholder',

                'view_table_header',
                'view_table_action',
                'view_placeholder',
                'view_btn',
                'view_tab_title',
                'view_text',
                'view_chart_title',

                'messages_success',
                'messages_info',
                'messages_warning',
                'messages_danger',

                'activity_description'
            ],
            strings: [],
            timeout: null,
            loading: false,
            pagination: {
                count: 0,
                current_page: 1,
                per_page: 40,
                range_before: 3,
                range_after: 3
            }
        }
    },
    mounted() {
        this.getBucketStrings()
    },
    methods: {

        changePagination(page) {
            this.pagination.current_page = page
            this.getBucketStrings()
        },

        getBucketStrings() {

            this.strings = []
            this.loading = true

            // get strings for module (default)
            let url = `/babel/translation/modules/${this.module.id}/strings.json`

            // if user selects bucket
            if (this.bucket.id) {
                url = `/babel/translation/modules/${this.module.id}/buckets/${this.bucket.id}/strings.json`
            }

            url += `?page=${this.pagination.current_page}&perPage=${this.pagination.per_page}`

            this.http.get(url).then(result => {
                if (!result.successful) return 
                this.strings = result.data.data ? result.data.data : []
                this.pagination.count = result.data.total ? result.data.total : 0
                this.loading = false
            }).catch(error => {
                console.log(error)
                this.loading = false
            })
           
        },

        postTranslationString() {
            this.http.post('/babel/translation/strings.json', {
                translation_string: {
                    context: '',
                    label: this.labelPrefix + "_" + this.label,
                    en: '',
                    es: '',
                    de: '',
                    cloud_babel_translation_buckets_id: this.bucket.id
                }
            }).then(result => {
                if (!result) this.alert("Error adding label", "danger")
                this.alert("Label successfully added", "success")
                this.getBucketStrings()
                this.label = ''
                this.labelPrefix = ''
            }).catch(error => {
                console.log(error)
            })
        }

    },
    watch: {
        'bucket': function() {
            this.getBucketStrings()
        },
        'module': function() {
            this.getBucketStrings()
        }
    }
}
</script>
<template>
    <section>
        <div class="card">
            <div class="card-header">
                <h4 class="card-header-title">
                    Labels
                </h4>
                <div class="card-header-icon" v-if="this.bucket.id">
                    <form @submit.prevent="postTranslationString()">
                        <div class="field has-addons">
                            <p class="control">
                                <a class="button is-static">
                                    Add new label:
                                </a>
                            </p>
                            <div class="control">
                                <b-select
                                    placeholder="Prefix"
                                    v-model="labelPrefix">
                                    <option v-for="prefix in prefixes" :key="prefix" :value="prefix">{{ prefix }}</option>
                                </b-select>
                            </div>
                            <div class="control">
                                <input class="input" type="text" v-model="label" placeholder="Add label to translation workflow" style="height: 36px;">
                            </div>
                        </div>
                    </form>
                </div>
            </div>
            <component-string-editor :strings="strings">
            </component-string-editor>
            <hr>
            <b-pagination
                :simple="false"
                :total="pagination.count"
                :current.sync="pagination.current_page"
                :range-before="pagination.range_before"
                :range-after="pagination.range_after"
                :per-page="pagination.per_page"
                @change="changePagination"
                order="is-centered"
                icon-prev="chevron-left"
                icon-next="chevron-right"
                aria-next-label="Next page"
                aria-previous-label="Previous page"
                aria-page-label="Page"
                aria-current-label="Current page"
            >
            </b-pagination>
            <br>
        </div>

        <component-data-loading class="section" v-if="loading"></component-data-loading>
        <component-data-empty v-if="!loading && strings.length == 0"></component-data-empty>

    </section>
</template>
