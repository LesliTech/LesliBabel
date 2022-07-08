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
onMounted(() => {

})


// · 
const prefixes = [{
    label: 'view_text',
    value: 'view_text'
}
/*
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
*/
]

</script>
<template>
    <div class="card">
        <div class="card-content pt-3">
            <h4 class="card-header-title p-1 pb-2">
                Add new label
            </h4>
            <form>
                <div class="field is-grouped">
                    <div class="control">
                        <lesli-select
                            v-model="selection"
                            :options="prefixes">
                        </lesli-select>
                    </div>
                    <div class="control is-expanded">
                        <input class="input" type="text" placeholder="Add label to translation workflow" />
                    </div>
                </div>
            </form>
        </div>
    </div>
</template>
