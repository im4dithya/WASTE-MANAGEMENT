"""waste_management URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path

from myapp import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('',views.login1),
     path('login1',views.login1),
    path('forgotpassword',views.forgotpassword),
    path('forgotpasswordbuttonclick',views.forgotpasswordbuttonclick),
    path('otp',views.otp),
    path('otpbuttonclick',views.otpbuttonclick),
    path('forgotpswdpswed',views.forgotpswdpswed),
    path('forgotpswdpswedbuttonclick',views.forgotpswdpswedbuttonclick),
    path('login1_post',views.login1_post),
    path('admin_home',views.admin_home),
    path('admin_add_area',views.admin_add_area),
    path('admin_add_area_post',views.admin_add_area_post),


    path('view_complaint',views.view_complaint),
    path('view_feedback',views.view_feedback),
    path('reply/<id>',views.reply),
    path('reply_post/<id>',views.reply_post),
    path('view_users',views.view_users),
    path('view_allocated_area',views.view_allocated_area),
    path('allocate_area_to_pickup',views.allocate_area_to_pickup),
    path('waste_edit',views.waste_edit),
    path('waste_type_add',views.waste_type_add),
    path('waste_view',views.waste_view),
    path('view_area',views.view_area),
    path('admin_edit_area/<id>',views.admin_edit_area),
    path('admin_edit_area_post/<id>',views.admin_edit_area_post),
    path('delete_area/<id>',views.delete_area),
    path('add_waste_type',views.add_waste_type),
    path('add_waste_type_post',views.add_waste_type_post),
    path('view_waste_type',views.view_waste_type),
    path('edit_waste_type/<id>',views.edit_waste_type),
    path('edit_waste_type_post/<id>',views.edit_waste_type_post),
    path('delete_waste_type/<id>',views.delete_waste_type),
    path('recycler_register',views.recycler_register),
    path('recycler_register_post',views.recycler_register_post),
    path('admin_view_recycler',views.admin_view_recycler),
    path('admin_verify_recycler/<id>',views.admin_verify_recycler),
    path('admin_reject_recycler/<id>',views.admin_reject_recycler),
    path('view_verified_recycler',views.view_verified_recycler),
    path('allocate_area_view/<id>',views.allocate_area_view),
    path('allocate_area_post/<id>',views.allocate_area_post),
    path('allocated_area',views.allocated_area),
    path('pickup_home',views.pickup_home),
    path('view_profile',views.view_profile),
    path('pickup_view_allocated_area',views.pickup_view_allocated_area),
    path('view_public_offence',views.view_public_offence),
    path('take_action/<id>',views.take_action),
    path('recycler_view_profile',views.recycler_view_profile),
    path('recycler_home',views.recycler_home),
    path('profile_edit/<id>',views.profile_edit),
    path('profile_edit_post/<id>',views.profile_edit_post),
    path('recycler_add_product',views.recycler_add_product),
    path('recycler_add_product_post',views.recycler_add_product_post),
    path('view_product',views.view_product),
    path('edit_product/<id>',views.edit_product),
    path('edit_product_post/<id>',views.edit_product_post),
    path('delete_product/<id>',views.delete_product),
    path('view_order_request',views.view_order_request),
    path('view_payment',views.view_payment),
    path('change_password_recycler',views.change_password_recycler),
    path('change_password_recycler_post',views.change_password_recycler_post),
    path('update_status/<id>',views.update_status),
    path('view_user_request',views.view_user_request),
    path('update_collection_date/<id>',views.update_collection_date),
    path('update_collection_date_post/<id>',views.update_collection_date_post),
    path('view_todays_collection',views.view_todays_collection),
    path('update_waste_status/<id>',views.update_waste_status),
    path('view_collection_history',views.view_collection_history),
    path('change_password_pickup',views.change_password_pickup),
    path('change_password_pickup_post',views.change_password_pickup_post),
    path('change_password_admin',views.change_password_admin),
    path('change_password_admin_post',views.change_password_admin_post),
    path('waste_item/<id>',views.waste_item),
    path('logiin_user',views.logiin_user),
    path('view_reply',views.view_reply),
    path('uview_waste_type',views.uview_waste_type),
    path('view_request_status',views.view_request_status),
    path('view_rewards',views.view_rewards),
    path('view_type',views.view_type),
    path('uview_product',views.uview_product),
    path('add_to_cart',views.add_to_cart),
    path('view_cart',views.view_cart),
    path('check_product_stock',views.check_product_stock),
    path('place_order',views.place_order),
    path('decrease_stock',views.decrease_stock),
    path('delete_cart_item',views.delete_cart_item),
    path('view_status',views.view_status),
    path('view_order_details',views.view_order_details),
    path('uview_payment',views.uview_payment),
    path('view_workers',views.view_workers),
    path('uprofile_edit',views.uprofile_edit),
    path('register_user',views.register_user),
    path('uview_area',views.uview_area),
    path('sendfeedback',views.sendfeedback),
    path('sendcomplaint',views.sendcomplaint),
    path('sndwasterequest',views.sndwasterequest),
    path('sndpublicoffence',views.sndpublicoffence),
    path('user_edit_profile',views.user_edit_profile),
    path('uview_public_offence',views.uview_public_offence),
    path('view_reward',views.view_reward),
    path('logout',views.logout_view),
    path('delivered_history',views.delivered_history),
    path('delete_allocated_area/<id>',views.delete_allocated_area),
    path('view_ordered_items/<int:id>', views.view_ordered_items, name='view_ordered_items'),
    path('forgotemail', views.forgotemail),
    path('forgotpass', views.forgotpass),
    path('loadPanchayath',views.loadPanchayath),
    path('changepassword_user',views.changepassword_user),
    path('allwaste_item/<id>',views.allwaste_item),











]
urlpatterns+=static(settings.MEDIA_URL,document_root=settings.MEDIA_ROOT)