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

Made with ♥ by LesliTech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · import vue tools
import { ref, reactive, onMounted, watch, computed, inject } from "vue"
import { useRouter, useRoute } from 'vue-router'


// · initialize/inject plugins
const router = useRouter()
const route = useRoute()
const msg = inject("msg")
const url = inject("url")


// · import components
import componentLabelEditor from "LesliBabel/vue/components/form-label-editor.vue"
import componentActions from "LesliBabel/vue/components/actions.vue"


// · import lesli stores
import { useStrings } from "LesliBabel/vue/stores/strings"
import { useTranslations } from "LesliBabel/vue/stores/translations"


// · implement stores
const storeStrings = useStrings()
const storeTranslations = useTranslations()


// · 
function search(string) {
    router.push({ path: "translations", query: { search: string }})
}
</script>
<template>
    <lesli-application-container>
        <lesli-header title="Translations">
            <component-actions></component-actions>
        </lesli-header>

        <lesli-toolbar :initial-value="storeStrings.search" @search="search">
        </lesli-toolbar>

        <component-label-editor>
        </component-label-editor>
    </lesli-application-container>
</template>
