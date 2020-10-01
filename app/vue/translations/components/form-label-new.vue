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



// · 
export default {
    props: {
        bucket: {},
        module: {}
    },
    data() {
        return {
            label: "",
            labelPrefix: "view_text",
            prefixes: [
                'activity_description',

                'column',
                'column_enum',

                'mailer',
                'messages_success',
                'messages_info',
                'messages_warning',
                'messages_danger',

                'sidebar_nav',

                'view',
                'view_btn',
                'view_chart_title',
                'view_placeholder',
                'view_tab_title',
                'view_table_action',
                'view_table_header',
                'view_text',
                'view_title',
                'view_toolbar_filter',
                'view_toolbar_filter_placeholder',
                'view_toolbar_search_by_placeholder',

            ],
            timeout: null,
            loading: false,
        }
    },
    methods: {

        postTranslationString() {
            this.http.post('/babel/translation/strings.json', {
                translation_string: {
                    context: '',
                    label: this.labelPrefix + "_" + this.label,
                    cloud_babel_translation_buckets_id: this.bucket.id
                }
            }).then(result => {
                if (!result) this.alert("Error adding label", "danger")
                this.alert("Label successfully added", "success")
                this.label = ''
            }).catch(error => {
                console.log(error)
            })

            this.bus.publish('post:/babel/translation/strings.json')
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
        </div>
    </section>
</template>
