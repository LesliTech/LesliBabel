<p align="center">
	<img width="75" alt="LesliBabel logo" src="./app/assets/images/lesli_babel/babel-logo.svg" />
    <h3 align="center">Translation Management System for the Lesli Framework.</h3>
</p>


<hr/>

<p align="center" class="is-flex is-justify-content-center">
    <a target="blank" href="https://rubygems.org/gems/lesli_babel">
        <img height="22" alt="Gem Version" src="https://badge.fury.io/rb/lesli_babel.svg" />
    </a>
    <a class="mx-2" href="https://codecov.io/github/LesliTech/Lesli"> 
        <img height="22" src="https://codecov.io/github/LesliTech/Lesli/graph/badge.svg?token=2O12NENK5Y"/> 
    </a>
    <a href="https://codecov.io/github/LesliTech/Lesli"> 
        <img height="22" src="https://sonarcloud.io/api/project_badges/measure?project=LesliTech_Lesli&metric=sqale_rating"/> 
    </a>
</p>

<hr/>


### Quick start

```shell
# Add LesliBabel engine
bundle add lesli_babel
```

```shell
# Setup database
rake lesli:db:setup
```

```ruby
# Load LesliBabel
Rails.application.routes.draw do
    mount LesliBabel::Engine => "/babel"
end
```


### Documentation
* [Website](https://www.lesli.dev/babel/)
* [Database](./docs/database.md)
* [Documentation](https://www.lesli.dev/documentation/)


### Get in touch

* [Website: https://www.lesli.tech](https://www.lesli.tech)
* [Email: hello@lesli.tech](hello@lesli.tech)
* [Twitter: @LesliTech](https://twitter.com/LesliTech)


### License
-------
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

<hr />
<br />

<p align="center">
    <img width="200" alt="Lesli logo" src="https://cdn.lesli.tech/lesli/brand/app-logo.svg" />
    <h4 align="center">Ruby on Rails SaaS Development Framework.</h4>
</p>

