<script>
/*
Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

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
                'account_init',
                'activity_description',

                'column',
                'column_enum',

                'mailer',
                'messages_success',
                'messages_info',
                'messages_warning',
                'messages_danger',

                'sidebar_nav',

                'error',

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
                'view_toolbar_search_by_placeholder'
            ],
            timeout: null,
            loading: false,
        }
    },
    methods: {

        postTranslationString() {
            this.http.post('/babel/strings.json', {
                string: {
                    cloud_babel_buckets_id: this.bucket.id,
                    context: '',
                    label: this.labelPrefix + "_" + this.label
                }
            }).then(result => {
                if (!result) {
                    this.msg.error("Error adding label")
                    return
                }
                this.label = ''
                this.data.label.getStrings()
                this.msg.success("Label successfully added")
            })
        }

    }
}
</script>
<template>
    <div class="card">
        <div class="card-header">
            <h4 class="card-header-title">
                Add new label
            </h4>
        </div>
        <div class="card-content">
            <form @submit.prevent="postTranslationString()">
                <div class="field is-grouped">
                    <div class="control">
                        <b-select
                            placeholder="Prefix"
                            v-model="labelPrefix">
                            <option v-for="prefix in prefixes" :key="prefix" :value="prefix">{{ prefix }}</option>
                        </b-select>
                    </div>
                    <div class="control is-expanded">
                        <input class="input" type="text" v-model="label" placeholder="Add label to translation workflow" style="height: 36px;">
                    </div>
                </div>
            </form>
        </div>
    </div>
</template>
