<script setup>
/*

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
*/


// · import vue tools
import { ref, reactive, onMounted, watch, computed, onUnmounted } from "vue"


// · 
import { useStrings } from "LesliBabel/stores/strings"
import { useModule } from "LesliBabel/stores/module"


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
    label: "column",
    value: "column"
}, {
    label: "message",
    value: "message"
}, {
    label: "navigation",
    value: "navigation"
}, {
    label: "error",
    value: "error"
}, {
    label: "button",
    value: "button"
}, {
    label: "chart",
    value: "chart"
}, {
    label: "tab_title",
    value: "tab_title"
}, {
    label: "table_action",
    value: "table_action"
}, {
    label: "table_header",
    value: "table_header"
}, {
    label: "title",
    value: "title"
}, {
    label: "toolbar",
    value: "toolbar"
}, {
    label: "view",
    value: "view"
}, {
    label: "view_text",
    value: "view_text"
}, {
    label: "view_placeholder",
    value: "view_placeholder"
}]


function postString() {
    storeString.post({
        bucket_id: bucket.value,
        context: '',
        label: prefix.value + "_" + string.value
    })

    string.value = ''   
}

</script>
<template>
    <lesli-form @submit="postString">
        <div class="card-content">
            <div class="field">
                <label class="label">Bucket</label>
                <div class="control">
                    <lesli-select
                        v-model="bucket"
                        :options="storeModule.buckets.map(b => { return { value: b.id, label: b.code }})">
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
    </lesli-form>
</template>
