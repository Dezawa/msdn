# -*- coding: utf-8 -*-
#Delayed::Worker.backend = :data_mapper
#Delayed::Worker.backend.auto_upgrade!
#dx

Delayed::Worker.max_attempts = 1 # リトライ回数
