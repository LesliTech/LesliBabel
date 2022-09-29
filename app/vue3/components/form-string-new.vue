<script setup>
/*
Copyright (c) 2022, all rights reserved.

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


// · import vue tools
import { ref, reactive, onMounted, watch, computed, onUnmounted } from "vue"


// · 
import { useStrings } from "CloudBabel/stores/strings"
import { useModule } from "CloudBabel/stores/module"


// · implement stores
const storeModule = useModule()
const storeString = useStrings()


// · 
const props = defineProps({
    moduleId: {
        type: Number,
        require: true
    }
})


// · 
onMounted(() => {

})


// · 
const bucket = ref('')
const prefix = ref('')
const string = ref('')


// · 
const prefixes = [{
    label: 'account_init',
    value: 'account_init'
}, {
    label: 'activity_description',
    value: 'activity_description'
}
/*
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
*/
]


function postString() {
    storeString.post({
        cloud_babel_buckets_id: bucket.value,
        context: '',
        label: prefix.value + "_" + string.value
    })

    string.value = ''   
}

</script>
<template>
    <form v-on:submit.prevent="postString" class="card is-shadowless">
        <div class="card-content">
            <div class="field">
                <label class="label">Bucket</label>
                <div class="control">
                    <lesli-select
                        v-model="bucket"
                        :options="storeModule.buckets.map(b => { return { value: b.id, label: b.name }})">
                    </lesli-select>
                </div>
            </div>
            <div class="field">
                <label class="label">Prefix</label>
                <div class="control">
                    <lesli-select
                        v-model="prefix"
                        :options="prefixes">
                    </lesli-select>
                </div>
            </div>
            <div class="field">
                <label class="label">Label</label>
                <div class="control">
                    <input required v-model="string" class="input" type="text" placeholder="Add label to translation workflow" />
                </div>
            </div>
            <div class="control">
                <input class="button is-primary" type="submit" value="Save" />
            </div>
        </div>
    </form>
</template>
