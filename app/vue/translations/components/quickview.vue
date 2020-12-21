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


// · Import core components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
import componentCloudObjectDiscussionSimple from 'LesliCoreVue/cloud_objects/discussion-simple.vue'
import componentCloudObjectActivitySimple from 'LesliCoreVue/cloud_objects/activity-simple.vue'

// · 
export default {
    props: {
        show: {
            type: Boolean,
            default: false
        },

        stringId: {
            required: true
        },

        toggleFunction: {
            required: true
        }
    },

    components: {
        'component-cloud-object-discussion-simple': componentCloudObjectDiscussionSimple,
        'component-cloud-object-activity-simple': componentCloudObjectActivitySimple
    },

    data() {
        return {
            active_tab: 0,
            translations: {
                core: I18n.t('deutscheleibrenten.shared')
            }
        }
    },
    methods: {
    }

}
</script>
<template>
    <div :class="[{ 'is-active': show }, 'quickview', 'is-size-large']">
        <header class="quickview-header">
            <h4 class="title">Discussions/Activities</h4>
            <span class="delete" @click="toggleFunction"></span>
        </header>
        <div class="quickview-body">
            <b-tabs expanded v-model="active_tab">
                <b-tab-item label="Discussions">
                    <component-cloud-object-discussion-simple
                        v-if="stringId"
                        cloud-module="babel/string" 
                        :cloud-id="stringId" 
                        translations-path="deutscheleibrenten.shared"
                    />
                </b-tab-item>
                <b-tab-item label="Activities Log">
                    <component-cloud-object-activity-simple
                        v-if="stringId" 
                        cloud-module="babel/string" 
                        :cloud-id="stringId"
                    />
                </b-tab-item>
            </b-tabs>

            <div class="quickview-block">
                
            </div>
        </div>
        <footer class="quickview-footer">

        </footer>
    </div>
</template>
