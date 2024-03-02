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
import { useString } from "LesliBabel/vue/stores/string"
import { useModule } from "LesliBabel/vue/stores/module"


// · implement stores
const storeModule = useModule()
const storeString = useString()


// · 
const props = defineProps({
    moduleId: {
        type: Number,
        require: true
    }
})


// · 
const bucket = ref('')
const prefix = ref('')
const string = ref('')


// · 
const components = [{
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
    label: "tab",
    value: "tab"
}, {
    label: "table",
    value: "table"
}, {
    label: "toolbar",
    value: "toolbar"
}, {
    label: "view",
    value: "view"
}]

</script>
<template>
    <lesli-form @submit="storeString.post()">
        <div class="card-content">
            <div class="field">
                <label class="label">Bucket</label>
                <div class="control">
                    <lesli-select
                        v-model="storeString.string.bucket_id"
                        :options="storeModule.buckets.map(b => { return { value: b.id, label: b.code }})">
                    </lesli-select>
                </div>
            </div>
            <div class="field">
                <label class="label">Component</label>
                <div class="control">
                    <lesli-select
                        v-model="storeString.component"
                        :options="components">
                    </lesli-select>
                </div>
            </div>
            <div class="field">
                <label class="label">Label</label>
                <div class="control">
                    <input required v-model="storeString.string.label" class="input" type="text" placeholder="Add label to translation workflow" />
                </div>
            </div>
            <div class="control">
                <input class="button is-primary" type="submit" value="Save" />
            </div>
        </div>
    </lesli-form>
</template>
