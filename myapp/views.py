import datetime
import random
import smtplib

from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.hashers import make_password, check_password
from django.contrib.auth.models import Group
from django.core.files.storage import FileSystemStorage
from django.http import HttpResponse, JsonResponse
from django.shortcuts import render

# Ceate your views here.
from django.views.decorators.cache import never_cache

from myapp.models import *


def login1(request):
    return render(request,'login.html')

def login1_post(request):
    un=request.POST['username']
    psw=request.POST['password']
    data=authenticate(request,username=un,password=psw)
    if data is not None:
        login(request,data)
        if data.is_superuser:
            return HttpResponse("<script>alert('success');window.location='/admin_home'</script>")

        if data.groups.filter(name='recycler').exists():
            obj=pickup_recycler.objects.get(LOGIN=data)
            if obj.status != 'accepted':
                return HttpResponse("<script>alert('Your account is not verified yet.');window.location='/'</script>")
            if obj.type == "pickup":
                request.session['pid']=obj.id
                return HttpResponse("<script>alert('success');window.location='/pickup_home'</script>")
            if obj.type == "recycler":
                request.session['rid']=obj.id
                return HttpResponse("<script>alert('success');window.location='/recycler_home'</script>")
    return HttpResponse("<script>alert('Invalid username or password');window.location='/'</script>")

@login_required(login_url='/')
def admin_home(request):
    return render(request, 'admin/admin _home.html')

@login_required(login_url='/')
def admin_add_area(request):
    return render(request,'admin/add_area.html')

@login_required(login_url='/')
def admin_add_area_post(request):
    dis=request.POST['select']
    pan=request.POST['textfield']
    lat=request.POST['textfield2']
    lon=request.POST['textfield3']

    if area.objects.filter(district=dis, panchayath=pan).exists():
        return HttpResponse("<script>alert('Area already exists');window.location='/admin_add_area'</script>")

    ob=area()
    ob.district=dis
    ob.panchayath=pan
    ob.latitude=lat
    ob.longitude=lon
    ob.save()

    return HttpResponse("<script>alert('Area added successfully');window.location='/view_area'</script>")

@login_required(login_url='/')
def view_area(request):
    data=area.objects.all()
    return render(request,'admin/view_area.html',{'data':data})

@login_required(login_url='/')
def admin_edit_area(request,id):
    data=area.objects.get(id=id)
    return render(request,'admin/edit_area.html',{'data':data})

@login_required(login_url='/')
def admin_edit_area_post(request,id):
    dis=request.POST['select']
    pan=request.POST['textfield']
    lat=request.POST['textfield2']
    lon=request.POST['textfield3']
    # Check for duplicate except for current id
    if area.objects.filter(district=dis, panchayath=pan).exclude(id=id).exists():
        return HttpResponse("<script>alert('Area already exists');window.location='/admin_edit_area/%s'</script>" % id)
    area.objects.filter(id=id).update(district=dis,panchayath=pan,latitude=lat,longitude=lon)
    return HttpResponse("<script>alert('Area updated successfully');window.location='/view_area'</script>")


@login_required(login_url='/')
def delete_area(request,id):
    data=area.objects.get(id=id)
    data.delete()
    return HttpResponse("<script>alert('Area deleted successfully');window.location='/view_area'</script>")

@login_required(login_url='/')
def add_waste_type(request):
    return render(request,'admin/waste_type_add.html')

@login_required(login_url='/')
def add_waste_type_post(request):
    was=request.POST['textfield']
    amou=request.POST['textfield2']
    note=request.POST['textfield3']
    reward=request.POST['textfield4']
    # Check for duplicate waste type
    if waste_type.objects.filter(waste=was).exists():
        return HttpResponse("<script>alert('Waste type already exists');window.location='/add_waste_type'</script>")
    ob=waste_type()
    ob.waste=was
    ob.amount=amou
    ob.note=note
    ob.reward=reward
    ob.save()
    return HttpResponse("<script>alert('success');window.location='/add_waste_type'</script>")

@login_required(login_url='/')
def view_waste_type(request):
    data=waste_type.objects.all()
    return render(request,'admin/waste_view.html',{'data':data})

@login_required(login_url='/')
def edit_waste_type(request,id):
    data=waste_type.objects.get(id=id)
    return render(request, 'admin/waste_edit.html', {'data': data})

@login_required(login_url='/')
def edit_waste_type_post(request,id):
    was=request.POST['textfield']
    amou=request.POST['textfield2']
    note=request.POST['textfield3']
    reward=request.POST['textfield4']
    # Check for duplicate waste type except for current id
    if waste_type.objects.filter(waste=was).exclude(id=id).exists():
        return HttpResponse("<script>alert('Waste type already exists');window.location='/edit_waste_type/%s'</script>" % id)
    waste_type.objects.filter(id=id).update(waste=was,amount=amou,note=note,reward=reward)
    return HttpResponse("<script>alert('edited');window.location='/view_waste_type'</script>")

@login_required
@never_cache
def delete_waste_type(request,id):
    data=waste_type.objects.get(id=id)
    data.delete()
    return HttpResponse("<script>alert('delete');window.location='/view_waste_type'</script>")


@login_required
@never_cache
def view_users(request):
    data=user.objects.all()
    return render(request,'admin/view_user.html',{"data":data})

def recycler_register(request):
    return render(request, 'recycler/registration.html')

def recycler_register_post(request):
    nam=request.POST['textfield']
    ph=request.POST['textfield2']
    ema=request.POST['textfield3']
    # Check if email already exists
    if User.objects.filter(username=ema).exists():
        return HttpResponse("<script>alert('Email already exists');window.location='/recycler_register'</script>")
    pht=request.FILES['fileField']
    fs=FileSystemStorage()
    photo=fs.save(pht.name,pht)
    prf=request.FILES['fileField2']
    fss = FileSystemStorage()
    proo = fss.save(prf.name, prf)
    typ=request.POST['select']
    psw=request.POST['textfield4']
    cpsw=request.POST['textfield5']
    if psw == cpsw:
        ob=User()
        ob.username=ema
        ob.password=make_password(psw)
        ob.save()
        ob.groups.add(Group.objects.get(name='recycler'))
        obj=pickup_recycler()
        obj.name=nam
        obj.phone=ph
        obj.email=ema
        obj.photo=fs.url(photo)
        obj.proof=fs.url(proo)
        obj.type=typ
        obj.status='pending'
        obj.LOGIN=ob
        obj.save()
        return HttpResponse("<script>alert('registered successfully');window.location='/'</script>")
    return HttpResponse("<script>alert('invalid');window.location='/recycler_register'</script>")

@login_required(login_url='/')
def admin_view_recycler(request):
    data=pickup_recycler.objects.filter(status='pending')
    return render(request,'admin/view recycler.html',{'data':data})

@login_required(login_url='/')
def admin_verify_recycler(request,id):
    pickup_recycler.objects.filter(id=id).update(status='accepted')
    return HttpResponse("<script>alert('accepted');window.location='/admin_view_recycler'</script>")


@login_required(login_url='/')
def admin_reject_recycler(request,id):
    pickup_recycler.objects.filter(id=id).update(status='rejected')
    return HttpResponse("<script>alert('rejected');window.location='/admin_view_recycler'</script>")


@login_required(login_url='/')
def view_verified_recycler(request):
    data = pickup_recycler.objects.filter(status='accepted')
    return render(request, 'admin/view verified recycler.html', {'data': data})



@login_required(login_url='/')
def allocate_area_view(request, id):
    data = pickup_recycler.objects.filter(type='pickup')
    return render(request, 'admin/allocate_area.html', {'data': data, 'id': id})


@login_required(login_url='/')
def allocate_area_post(request, id):
    pickup = request.POST['select']
    # Check for duplicate allocation
    if allocatearea.objects.filter(AREA_id=id, PICKUP_id=pickup).exists():
        return HttpResponse("<script>alert('This area is already allocated to the selected pickup.');window.location='/allocated_area'</script>")
    obj = allocatearea()
    obj.AREA_id = id
    obj.PICKUP_id = pickup
    obj.date = datetime.datetime.now().date()
    obj.save()
    return HttpResponse("<script>alert('allocated');window.location='/allocated_area'</script>")


@login_required(login_url='/')
def allocated_area(request):
    data=allocatearea.objects.all()
    return render(request,'admin/view_allocated_area.html',{'data':data})


@login_required(login_url='/')
def view_feedback(request):
    data=feedback.objects.all()
    return  render(request,'admin/view_feedback.html',{"data":data})



@login_required(login_url='/')
def view_complaint(request):
    data=complaint.objects.all()
    return render(request,'admin/view_complaint.html',{"data":data})


@login_required(login_url='/')
def reply(request,id):
    return render(request,'admin/reply.html',{'id':id})
@login_required(login_url='/')
def reply_post(request,id):
    rp=request.POST['textfield']
    complaint.objects.filter(id=id).update(reply=rp,replydate=datetime.date.today())
    return HttpResponse("<script>alert('sended');window.location='/view_complaint'</script>")

@login_required(login_url='/')
def view_public_offence(request):
    data=offence.objects.all()
    return render(request,'admin/view_public_offence_and_take_action.html',{"data":data})

def uview_public_offence(request):
    """API endpoint to view public offences for Flutter"""
    data = offence.objects.filter(USER=request.POST['uid']).order_by('-date')
    ar = []
    for i in data:
        ar.append({
            'id': i.id,
            'photo': i.photo,
            'username': i.USER.name if i.USER else 'Unknown',
            'status': i.status,
            'date': i.date,
            'latitude': i.latitude,
            'longitude': i.longitude,
        })
    return JsonResponse({"status": "ok", "data": ar})

@login_required(login_url='/')
def take_action(request,id):
    offence.objects.filter(id=id).update(status='take_action')
    # Only deduct if points were actually used


    # Add credit points earned from this purchase
    udata = offence.objects.filter(id=id)[0].USER
    new_rewards = int(udata.rewards) + 2
    udata.rewards = new_rewards  # Ensure non-negative
    udata.save()
    return HttpResponse("<script>alert('take action');window.location='/view_public_offence'</script>")



@login_required(login_url='/')
def view_allocated_area(request):
    return render(request,'admin/view_allocated_area.html')

@login_required(login_url='/')
def allocate_area_to_pickup(request):
    return render(request,'admin/allocate_area_to_pickup.html')

@login_required(login_url='/')
def waste_edit(request):
    return render(request,'admin/waste_edit.html')

@login_required(login_url='/')
def waste_type_add(request):
    return render(request,'admin/waste_type_add.html')

@login_required(login_url='/')
def waste_view(request):
    return render(request,'admin/waste_view.html')


@login_required(login_url='/')
def change_password_admin(request):
    return render(request,'admin/change_password_admin.html')
@login_required(login_url='/')
def change_password_admin_post(request):
    passw=request.POST['textfield']
    newpassword=request.POST['textfield2']
    confirmpassword=request.POST['textfield3']
    data=check_password(passw,request.user.password)
    if data:
        if newpassword == confirmpassword:
            obj=request.user
            obj.set_password(newpassword)
            obj.save()
            return HttpResponse("<script>alert('updated successfully');window.location='/'</script>")
    else:
        return HttpResponse("<script>alert('invalid username and password');window.location='/change_password_admin'</script>")


#---------------PIckup======================
@login_required(login_url='/')
def pickup_home(request):
    return render(request,'PICKUP_/pickuphome.html')

@login_required(login_url='/')
def view_profile(request):
    data=pickup_recycler.objects.get(id=request.session['pid'])
    return render(request,'PICKUP_/view profile.html',{'data':data})
@login_required(login_url='/')
def pickup_view_allocated_area(request):
    import json
    data=allocatearea.objects.filter(PICKUP_id=request.session['pid'])
    
    # Prepare areas with geofencing data
    areas_list = []
    for area_obj in data:
        areas_list.append({
            'id': area_obj.id,
            'district': area_obj.AREA.district,
            'panchayath': area_obj.AREA.panchayath,
            'latitude': float(area_obj.AREA.latitude),
            'longitude': float(area_obj.AREA.longitude),
            'date': area_obj.date,
        })
    
    return render(request,'PICKUP_/view allocated area.html',{
        "data": data,
        "areas_json": json.dumps(areas_list),
        "geofence_radius": 500
    })

@login_required(login_url='/')
def waste_item(request,id):
    data=waste_request_type.objects.filter(WASTEREQUEST=id)
    return render(request,'PICKUP_/waste_items.html',{'data':data,'id':id})



@login_required(login_url='/')
def allwaste_item(request,id):
    data=waste_request_type.objects.filter(WASTEREQUEST=id)
    return render(request,'PICKUP_/all_waste_items.html',{'data':data,'id':id})



@login_required(login_url='/')
def recycler_home(request):
    return render(request,'recycler/recyclerhome.html')

@login_required(login_url='/')
def recycler_view_profile(request):
    data=pickup_recycler.objects.filter(id=request.session['rid'])
    return render(request,'recycler/view_profile.html',{'data':data})

@login_required(login_url='/')
def profile_edit(request,id):
    data = pickup_recycler.objects.get(id=id)
    return render(request, 'recycler/edit_profile.html', {'data': data})
@login_required(login_url='/')
def profile_edit_post(request, id):
    nam = request.POST['textfield']
    em = request.POST['textfield2']
    phn = request.POST['textfield3']
    update_data = {'name': nam, 'email': em, 'phone': phn}

    if 'fileField' in request.FILES:
        ph = request.FILES['fileField']
        fs = FileSystemStorage()
        photo = fs.save(ph.name, ph)
        update_data['photo'] = fs.url(photo)
    if 'fileField2' in request.FILES:
        prf = request.FILES['fileField2']
        fss = FileSystemStorage()
        proof = fss.save(prf.name, prf)
        update_data['proof'] = fss.url(proof)

    pickup_recycler.objects.filter(id=id).update(**update_data)
    return HttpResponse("<script>alert('edited');window.location='/recycler_view_profile'</script>")


@login_required(login_url='/')
def recycler_add_product(request):
    return render(request,'recycler/add_product.html')
@login_required(login_url='/')
def recycler_add_product_post(request):
    nam=request.POST['textfield']
    pht=request.FILES['fileField']
    fs=FileSystemStorage()
    path=fs.save(pht.name,pht)
    prc=request.POST['textfield2']
    qt=request.POST['textfield3']
    if product.objects.filter(name=nam,price=prc,qty=qt,RECYCLER_id=request.session['rid']).exists():
        return HttpResponse("<script>alert('Exist');window.location='/recycler_home'</script>")

    ob=product()
    ob.name=nam
    ob.photo=fs.url(path)
    ob.price=prc
    ob.qty=qt
    ob.RECYCLER_id=request.session['rid']
    ob.save()

    return HttpResponse("<script>alert('added');window.location='/recycler_home'</script>")
@login_required(login_url='/')
def view_product(request):
    data=product.objects.filter(RECYCLER=request.session['rid'])
    return render(request,'recycler/view_product.html',{'data':data})

@login_required(login_url='/')
def edit_product(request,id):
    data=product.objects.get(id=id)
    return render(request,'recycler/edit_product.html',{'data':data})
@login_required(login_url='/')
def edit_product_post(request,id):
    nam=request.POST['textfield']
    if 'fileField' in request.FILES:
        pht=request.FILES['fileField']
        fs=FileSystemStorage()
        path=fs.save(pht.name,pht)
        product.objects.filter(id=id).update(photo=fs.url(path))
    prc=request.POST['textfield2']
    qt=request.POST['textfield3']
    if product.objects.filter(name=nam, price=prc, qty=qt, RECYCLER_id=request.session['rid']).exists():
        return HttpResponse("<script>alert('Exist');window.location='/recycler_home'</script>")
    product.objects.filter(id=id).update(name=nam,price=prc,qty=qt)
    return HttpResponse("<script>alert('success');window.location='/view_product'</script>")
@login_required(login_url='/')
def delete_product(request,id):
    data=product.objects.get(id=id)
    data.delete()
    return HttpResponse("<script>alert('delete');window.location='/view_product'</script>")
@login_required(login_url='/')
def view_order_request(request):
    data=order.objects.filter(RECYCLER_id=request.session['rid'],status="completed")
    return render(request,'recycler/view_order_request.html',{'data':data})
@login_required(login_url='/')
def view_ordered_items(request, id):
    items = ordersub.objects.filter(ORDER_id=id)
    order_obj = order.objects.get(id=id)
    return render(request, 'recycler/view_ordered_items.html', {'items': items, 'order': order_obj})

@login_required(login_url='/')
def update_status(request, id):
    order.objects.filter(id=id).update(status="delivered")
    return HttpResponse("<script>alert('Delivery status updated to delivered successfully');window.location='/view_product'</script>")

@login_required(login_url='/')
def delivered_history(request):
    delivered_orders = order.objects.filter(status="delivered",RECYCLER_id=request.session['rid'])
    return render(request, 'recycler/delivered_history.html', {'data': delivered_orders})

@login_required(login_url='/')
def view_payment(request):
    # Get all orders for the current recycler
    orders = order.objects.filter(RECYCLER_id=request.session['rid']).order_by('date')
    
    # Organize data by month
    monthly_report = {}
    
    for ord in orders:
        try:
            # Parse date (handles both date string formats)
            from datetime import datetime
            if isinstance(ord.date, str):
                date_obj = datetime.strptime(ord.date, '%Y-%m-%d')
            else:
                date_obj = ord.date
            
            month_key = date_obj.strftime('%B %Y')  # "January 2026"
            
            if month_key not in monthly_report:
                monthly_report[month_key] = {
                    'online': {'count': 0, 'total': 0},
                    'offline': {'count': 0, 'total': 0},
                    'grand_total': 0,
                    'orders': []
                }
            
            amount = float(ord.amount) if ord.amount else 0
            
            # Categorize by payment mode
            if ord.paymentmode and ord.paymentmode.lower() == 'online':
                monthly_report[month_key]['online']['count'] += 1
                monthly_report[month_key]['online']['total'] += amount
            else:
                monthly_report[month_key]['offline']['count'] += 1
                monthly_report[month_key]['offline']['total'] += amount
            
            monthly_report[month_key]['grand_total'] += amount
            monthly_report[month_key]['orders'].append(ord)
        
        except (ValueError, AttributeError) as e:
            # Skip orders with invalid date format
            continue
    
    # Calculate overall totals
    total_online = sum(month['online']['total'] for month in monthly_report.values())
    total_offline = sum(month['offline']['total'] for month in monthly_report.values())
    overall_total = total_online + total_offline
    
    context = {
        'data': orders,
        'monthly_report': monthly_report,
        'total_online': total_online,
        'total_offline': total_offline,
        'overall_total': overall_total,
    }
    
    return render(request, 'recycler/view_payment.html', context)

@login_required(login_url='/')
def change_password_recycler(request):
    return render(request,'recycler/change_password_recycler.html')
@login_required(login_url='/')
def change_password_recycler_post(request):
    passw=request.POST['textfield']
    newpassword=request.POST['textfield2']
    confirmpassword=request.POST['textfield3']
    data=check_password(passw,request.user.password)
    if data:
        if newpassword == confirmpassword:
            obj=request.user
            obj.set_password(newpassword)
            obj.save()
            return HttpResponse("<script>alert('updated successfully');window.location='/'</script>")
    else:
        return HttpResponse("<script>alert('invalid username and password');window.location='/'</script>")

@login_required(login_url='/')
def view_user_request(request):
    # Get allocated areas for current pickup worker
    allocated_areas = allocatearea.objects.filter(PICKUP_id=request.session['pid']).values_list('AREA_id', flat=True)
    
    # Get waste requests with pending collection date from users in allocated areas
    data = wasterequest.objects.filter(
        USER__AREA_id__in=allocated_areas,
        collectiondate='pending'
    ).select_related('USER', 'USER__AREA').order_by('requesteddate')
    
    return render(request,'PICKUP_/view_user_request.html',{'data':data})

@login_required(login_url='/')
def update_collection_date(request,id):
    return render(request,'PICKUP_/update_collection_date.html',{'id':id})
@login_required(login_url='/')
def update_collection_date_post(request,id):
    collectiondate=request.POST['textfield']
    obj=wasterequest.objects.get(id=id)
    obj.collectiondate=collectiondate
    obj.status="scheduled"
    obj.save()
    return HttpResponse("<script>alert('updated successfully');window.location='/view_user_request'</script>")

@login_required(login_url='/')
def view_todays_collection(request):
    import datetime
    allocated_areas = allocatearea.objects.filter(PICKUP_id=request.session['pid']).values_list('AREA_id', flat=True)
    
    # Get waste requests scheduled for today
    today = datetime.datetime.now().date()
    # today_str = today.strftime('%Y-%m-%d')
    
    data = wasterequest.objects.filter(
        USER__AREA_id__in=allocated_areas,
        collectiondate=today,
        status='scheduled'

    ).select_related('USER', 'USER__AREA').order_by('requesteddate')
    
    return render(request,'PICKUP_/view_todats_collection.html',{'data':data, 'today': today})

@login_required(login_url='/')
def update_waste_status(request,id):
    wid = request.POST.getlist('textfield')
    collectedqty = request.POST.getlist('textfield2')
    reward = 0
    for i in range(0,len(wid)):
        rewrad_current = waste_request_type.objects.get(id=wid[i]).WASTETYPE.reward
        reward += int(collectedqty[i]) * int(rewrad_current)
        waste_request_type.objects.filter(id=wid[i]).update(collectedqty=collectedqty[i])

    # Get the wasterequest object to fetch user_id
    waste_request_obj = wasterequest.objects.get(id=id)
    
    # Update wasterequest status and reward
    waste_request_obj.status = "collected"
    waste_request_obj.reward = reward
    waste_request_obj.save()
    
    # Update user rewards - add collected reward to user's total rewards
    user_obj = user.objects.get(id=waste_request_obj.USER_id)
    current_user_rewards = int(user_obj.rewards) if user_obj.rewards else 0
    user_obj.rewards = current_user_rewards + reward
    user_obj.save()
    
    return HttpResponse("<script>alert('updated successfully');window.location='/view_todays_collection'</script>")



@login_required(login_url='/')
def view_collection_history(request):
    # Get allocated areas for current pickup worker
    allocated_areas = allocatearea.objects.filter(PICKUP_id=request.session['pid']).values_list('AREA_id', flat=True)
    
    # Get collected waste requests from users in allocated areas
    data = wasterequest.objects.filter(
        USER__AREA_id__in=allocated_areas,
        status='collected'
    ).select_related('USER', 'USER__AREA').prefetch_related('waste_request_type_set').order_by('-collectiondate')
    
    # Build collection history with waste details
    collection_history = []
    total_units = 0
    total_rewards = 0
    
    for collection in data:
        waste_items = collection.waste_request_type_set.all().select_related('WASTETYPE')
        collection_dict = {
            'id': collection.id,
            'user': collection.USER,
            'area': collection.USER.AREA,
            'collectiondate': collection.collectiondate,
            'requesteddate': collection.requesteddate,
            'reward': collection.reward,
            'status': collection.status,
            'waste_items': waste_items
        }
        collection_history.append(collection_dict)
        
        # Calculate totals
        for waste in waste_items:
            if waste.collectedqty and waste.collectedqty != 'pending':
                total_units += int(waste.collectedqty)
        
        if collection.reward and collection.reward != 'pending':
            total_rewards += int(collection.reward)
    
    return render(request,'PICKUP_/view_collection_history.html',{
        'data': collection_history,
        'total_units': total_units,
        'total_rewards': total_rewards
    })

@login_required(login_url='/')
def change_password_pickup(request):
    return render(request,'PICKUP_/change_password_pickup.html')
@login_required(login_url='/')
def change_password_pickup_post(request):
    passw=request.POST['textfield']
    newpassword=request.POST['textfield2']
    confirmpassword=request.POST['textfield3']
    data=check_password(passw,request.user.password)
    if data:
        if newpassword == confirmpassword:
            obj=request.user
            obj.set_password(newpassword)
            obj.save()
            return HttpResponse("<script>alert('updated successfully');window.location='/'</script>")
    else:
        return HttpResponse("<script>alert('invalid username and password');window.location='/'</script>")


def forgotpassword(request):
    return render(request,"forgotpassword.html")
def forgotpasswordbuttonclick(request):
    email = request.POST['textfield']
    if User.objects.filter(username=email).exists():
        from email.mime.text import MIMEText
        from email.mime.multipart import MIMEMultipart

        # ✅ Gmail credentials (use App Password, not real password)
        sender_email = "itzspexx@gmail.com"
        receiver_email = email  # change to actual recipient
        app_password = "wrim jepf ezhu rtpb"  # App Password from Google
        pwd = str(random.randint(1100,9999))  # Example password to send
        request.session['otp'] = pwd
        request.session['email'] = email

        # Setup SMTP
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls()
        server.login(sender_email, app_password)

        # Create the email
        msg = MIMEMultipart("alternative")
        msg["From"] = sender_email
        msg["To"] = receiver_email
        msg["Subject"] = "Your OTP"

        # Plain text (backup)
        # text = f"""
        # Hello,

        # Your password for Smart Donation Website is: {pwd}

        # Please keep it safe and do not share it with anyone.
        # """

        # HTML (attractive)
        html = f"""
        <html>
          <body style="font-family: Arial, sans-serif; color: #333;">
            <h2 style="color:#2c7be5;">Wastemanagement</h2>
            <p>Hello,</p>
            <p>Your OTP is:</p>
            <p style="padding:10px; background:#f4f4f4; 
                      border:1px solid #ddd; 
                      display:inline-block;
                      font-size:18px;
                      font-weight:bold;
                      color:#2c7be5;">
              {pwd}
            </p>
            <p>Please keep it safe and do not share it with anyone.</p>
            <hr>
            <small style="color:gray;">This is an automated email from Wastemanagement System.</small>
          </body>
        </html>
        """

        # Attach both versions
        # msg.attach(MIMEText(text, "plain"))
        msg.attach(MIMEText(html, "html"))

        # Send email
        server.send_message(msg)
        print("✅ Email sent successfully!")

        # Close connection
        server.quit()
        return HttpResponse("<script>window.location='/otp'</script>")
    else:
        return HttpResponse("<script>alert('Email not found');window.location='/forgotpassword'</script>")


def otp(request):
    return render(request,"otp.html")
def otpbuttonclick(request):
    otp  = request.POST["textfield"]
    if otp == str(request.session['otp']):
        return HttpResponse("<script>window.location='/forgotpswdpswed'</script>")
    else:
        return HttpResponse("<script>alert('incorrect otp');window.location='/otp'</script>")

def forgotpswdpswed(request):
    return render(request,"forgotpswdpswed.html")
def forgotpswdpswedbuttonclick(request):
    np = request.POST["password"]
    User.objects.filter(username=request.session['email']).update(password=make_password(np))
    return HttpResponse("<script>alert('password has been changed');window.location='/' </script>")


def logiin_user(request):
    username=request.POST['username']
    password=request.POST['password']
    print(username,password)
    data=authenticate(request,username=username,password=password)
    print(data)
    if data is not None:
        login(request,data)
        if data.groups.filter(name='user').exists():
            uid=user.objects.get(LOGIN=request.user.id).id
            return JsonResponse({'status':'ok','uid':uid})
        return JsonResponse({'status': 'invalid'})
    return JsonResponse({'status': 'invalid'})


def view_reply(request):
    data=complaint.objects.filter(USER=request.POST['uid'])
    ar=[]
    for i in data:
        ar.append({
            'id':i.id,
            'complaint':i.complaint,
            'complaintdate':i.complaintdate,
            'reply':i.reply,
            'reply_date':i.replydate,
            'username':i.USER.name,
        })
    return  JsonResponse({"status":"ok","data":ar})



def uview_waste_type(request):
    data=waste_type.objects.all()
    ar=[]
    for i in data:
        ar.append({
            'id':i.id,
            'waste':i.waste,
            'amount':i.amount,
            'note':i.note,
            'reward':i.reward,
        })
    return JsonResponse({"status": "ok", "data": ar})


def view_request_status(request):
    data=wasterequest.objects.filter(USER=request.POST['uid'])
    ar=[]
    for i in data:
        ar.append({
            'id': i.id,
            'username': i.USER.name,
            'amount': i.amount,
            'collectiondate': i.collectiondate,
            'status':i.status,
            'requesteddate':i.requesteddate,
            'reward':i.reward,

        })
    return JsonResponse({"status": "ok", "data": ar})

def view_rewards(request):
    uid = request.POST.get('uid')
    data = wasterequest.objects.filter(USER_id=uid).order_by('-requesteddate')
    ar = []
    total_reward = 0
    
    for i in data:
        reward = int(i.reward) if i.reward and i.reward != 'pending' else 0
        total_reward += reward
        ar.append({
            'id': i.id,
            'username': i.USER.name,
            'amount': i.amount,
            'collectiondate': i.collectiondate,
            'status': i.status,
            'requesteddate': i.requesteddate,
            'reward': i.reward,
        })
    print(ar,"po")
    return JsonResponse({"status": "ok", "data": ar, "total_reward": int(data[0].USER.rewards)})

def view_type(request):
    data=waste_type.objects.all()
    ar=[]
    for i in data:
        ar.append({
            'id': i.id,
            'waste':i.waste,
            'amount':i.amount,
            'note':i.note,
            'rewards':i.rewards,

        })
    return JsonResponse({"status": "ok", "data": ar})

def uview_product(request):
    data=product.objects.all()
    ar=[]
    for i in data:
        ar.append({
            'id':i.id,
            'recyclername':i.RECYCLER.name,
            'name':i.name,
            'photo':i.photo,
            'price':i.price,
            'quantity':i.qty,

        })
    return JsonResponse({"status": "ok", "data": ar})

def add_to_cart(request):
    """Add product to user's cart"""
    try:
        uid = request.POST.get('uid')
        product_id = request.POST.get('product_id')
        quantity = request.POST.get('quantity')
        
        if not uid or not product_id or not quantity:
            return JsonResponse({"status": "error", "message": "Missing required fields"}, status=400)
        
        # Check if product exists
        product_obj = product.objects.get(id=product_id)
        user_obj = user.objects.get(id=uid)
        
        # Check if item already in cart for this user and product
        existing_cart_item = cart.objects.filter(USER_id=uid, PRODUCT_id=product_id).first()
        
        if existing_cart_item:
            # Update quantity
            existing_cart_item.qty = str(int(existing_cart_item.qty) + int(quantity))
            existing_cart_item.save()
        else:
            # Create new cart item
            cart_item = cart()
            cart_item.USER_id = uid
            cart_item.PRODUCT_id = product_id
            cart_item.qty = quantity
            cart_item.save()
        
        return JsonResponse({"status": "ok", "message": "Product added to cart successfully"})
    
    except product.DoesNotExist:
        return JsonResponse({"status": "error", "message": "Product not found"}, status=404)
    except user.DoesNotExist:
        return JsonResponse({"status": "error", "message": "User not found"}, status=404)
    except (ValueError, TypeError) as e:
        return JsonResponse({"status": "error", "message": "Invalid data format"}, status=400)
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)}, status=500)

def view_cart(request):
    """Get cart items for the current user"""
    try:
        uid = request.POST.get('uid')
        if not uid:
            return JsonResponse({"status": "error", "message": "User ID required"}, status=400)
        
        data = cart.objects.filter(USER_id=uid)
        ar = []
        for i in data:
            ar.append({
                'id': i.id,
                'username': i.PRODUCT.RECYCLER.name,
                'product': i.PRODUCT.name,
                'quantity': i.qty,
                'price': i.PRODUCT.price,
                'stock':i.PRODUCT.qty
            })
        return JsonResponse({"status": "ok", "data": ar})
    
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)}, status=500)

def view_status(request):
    """Get all waste requests with detailed waste items for the user"""
    try:
        uid = request.POST.get('uid')
        if not uid:
            return JsonResponse({"status": "error", "message": "User ID required"}, status=400)
        
        # Get all waste requests for the user
        waste_requests = wasterequest.objects.filter(USER_id=uid).order_by('-requesteddate')
        ar = []
        
        for wr in waste_requests:
            # Get all waste items for this request
            waste_items = waste_request_type.objects.filter(WASTEREQUEST_id=wr.id)
            
            items_list = []
            total_collected_qty = 0
            
            for wi in waste_items:
                collected_qty = int(wi.collectedqty) if wi.collectedqty and wi.collectedqty != 'pending' else 0
                base_qty = int(wi.baseqty) if wi.baseqty and wi.baseqty != 'pending' else 0
                total_collected_qty += collected_qty
                
                items_list.append({
                    'id': wi.id,
                    'waste_type': wi.WASTETYPE.waste if wi.WASTETYPE else 'Unknown',
                    'base_quantity': base_qty,
                    'collected_quantity': collected_qty,
                    'reward_per_unit': float(wi.WASTETYPE.reward) if wi.WASTETYPE and wi.WASTETYPE.reward else 0,
                })
            
            ar.append({
                'id': wr.id,
                'requested_date': str(wr.requesteddate),
                'collection_date': str(wr.collectiondate) if wr.collectiondate != 'pending' else 'pending',
                'status': wr.status,
                'total_reward': int(wr.reward) if wr.reward and wr.reward != 'pending' else 0,
                'total_collected_qty': total_collected_qty,
                'waste_items': items_list,
                'items_count': len(items_list),
            })
        
        return JsonResponse({"status": "ok", "data": ar})
    
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)}, status=500)



def uview_payment(request):
    data=ordersub.objects.filter(ORDER__USER=request.POST['uid'])
    ar=[]
    for i in data:
        ar.append({
            'id':i.id,
            'date':i.ORDER.date,
            'status':i.ORDER.status,
            'recyclername':i.ORDER.RECYCLER.name,
            'payementmode':i.ORDER.paymentmode,
            'amount':i.ORDER.amount,
            'qty':i.qty,
            'productname':i.PRODUCT.name,
            'price':i.PRODUCT.price,
            'photo':i.PRODUCT.photo,
            'total':int(i.qty)*int(i.PRODUCT.price),
            'orderid':i.ORDER.id,

        })
    return JsonResponse({"status": "ok", "data": ar})


def view_workers(request):
    data=pickup_recycler.objects.all()
    ar=[]
    for i in data:
        ar.append({
            'id':i.id,
            'name':i.name,
            'email':i.email,
            'phonenumber':i.phone,
            'photo':i.photo,
            'proof':i.proof,
            'status':i.status,
            'type':i.type,
        })
    return JsonResponse({"status": "ok", "data": ar})

def uprofile_edit(request):
    uid=request.POST['uid']
    data=user.objects.filter(id=uid)
    ar=[]
    for i in data:
        ar.append({
            'id':i.id,
            'name':i.name,
            'email':i.email,
            'area':i.AREA.panchayath,
            'phonenumber':i.phone,
            'housename':i.housename,
            'post':i.post,
            'pin':i.pin,
            'latitude':i.latitude,
            'longitude':i.longitude,
            'rewards':i.rewards,
        })
        print(ar)
    return JsonResponse({"status": "ok", "data": ar})
def user_edit_profile(request):
    # Expecting 'uid' in POST
    uid = request.POST.get('uid')
    if not uid:
        return JsonResponse({"status": "error", "message": "uid required"}, status=400)

    name = request.POST.get('name', '')
    email = request.POST.get('email', '')
    area_value = request.POST.get('area', '')
    phone = request.POST.get('phonenumber') or request.POST.get('phone', '')
    housename = request.POST.get('housename', '')
    post = request.POST.get('post', '')
    pin = request.POST.get('pin', '')
    latitude = request.POST.get('latitude', '')
    longitude = request.POST.get('longitude', '')

    update_data = {
        'name': name,
        'email': email,
        'phone': phone,
        'housename': housename,
        'post': post,
        'pin': pin,
        'latitude': latitude,
        'longitude': longitude,

    }

    # Resolve AREA: allow passing AREA id or panchayath name (skip if empty)
    if area_value and area_value.strip():
        try:
            # numeric id
            aid = int(area_value)
            update_data['AREA_id'] = aid
        except ValueError:
            # try to find area by panchayath name
            aobj = area.objects.filter(panchayath=area_value).first()
            if aobj:
                update_data['AREA_id'] = aobj.id

    user.objects.filter(id=uid).update(**update_data)
    return JsonResponse({"status": "ok"})


def uview_area(request):
    data=area.objects.all()
    are=[]
    for i in data:
        are.append({
            'id':i.id,
            'district':i.district,
            'panchayath':i.panchayath,
            'latitude':i.latitude,
            'longitude':i.longitude,
        })


    print(are)

    return JsonResponse({"status": "ok", "data": are})


def loadPanchayath(request):
    data = area.objects.all()
    are = []
    for i in data:
        are.append({
            'id': i.id,
            'district': i.district,
            'panchayath': i.panchayath,
        })
    return JsonResponse({"status": "ok", "data": are})




def register_user(request):
    area=request.POST['area']
    name=request.POST['name']
    email=request.POST['email']
    phone=request.POST['phone']
    housename=request.POST['housename']
    post=request.POST['post']
    pin=request.POST['pin']

    latitude=request.POST['latitude']
    longitude=request.POST['longitude']
    password=request.POST['password']
    confirm_password=request.POST['confirm_password']
    print(password)

    if User.objects.filter(username=email).exists():
        return JsonResponse({"status": "exist"})


    if password == confirm_password:

        obj1=User()
        obj1.username=email
        obj1.password=make_password(confirm_password)
        obj1.save()
        obj1.groups.add(Group.objects.get(name="user"))


        obj=user()
        obj.AREA_id=area
        obj.name=name
        obj.email=email
        obj.phone=phone
        obj.housename=housename
        obj.post=post
        obj.pin=pin
        obj.login=login
        obj.latitude=latitude
        obj.longitude=longitude
        obj.LOGIN_id=obj1.id
        obj.save()

        return JsonResponse({"status": "ok"})
    return JsonResponse({"status": "invalid"})


def sendfeedback(request):
    feed = request.POST['feedback']
    uid = request.POST['uid']
    if feedback.objects.filter(feedback = feed,date = datetime.datetime.now().date()).exists():
        return JsonResponse({"status": "exist"})

    print(uid,feed)
    obj = feedback()
    obj.feedback = feed
    obj.date = datetime.datetime.now().date()
    obj.USER_id = uid
    obj.save()
    return JsonResponse({"status": "ok"})


def sendcomplaint(request):
    comp = request.POST['complaint']
    uid = request.POST['uid']
    if complaint.objects.filter(complaint = comp,complaintdate = datetime.datetime.now().date()).exists():
        return JsonResponse({"status": "exist"})
    print(uid,comp)
    obj = complaint()
    obj.complaint = comp
    obj.reply ="pending"
    obj.replydate = "pending"
    obj.complaintdate = datetime.datetime.now().date()
    obj.USER_id = uid
    obj.save()
    return JsonResponse({"status": "ok"})


def sndwasterequest(request):
    id = request.POST.get('id')
    uid = request.POST.get('uid')
    quantity = request.POST.get('quantity', 'pending')
    
    print(f'uid: {uid}, id: {id}, quantity: {quantity}')

    if wasterequest.objects.filter(USER_id=uid, status='pending', collectiondate='pending').exists():
        obj = wasterequest.objects.get(USER_id=uid, status='pending', collectiondate='pending')
        ob = waste_request_type()
        ob.WASTEREQUEST_id = obj.id
        ob.WASTETYPE_id = id
        ob.collectedqty = "pending"
        ob.baseqty = quantity if quantity != 'pending' else "pending"
        ob.save()    
    else:
    
        obj = wasterequest()
        obj.USER_id = uid
        obj.amount = quantity if quantity != 'pending' else "pending"
        obj.status = "pending"
        obj.collectiondate = "pending"
        obj.reward = "pending"
        obj.requesteddate = datetime.datetime.now().date()
        obj.save()

        
        ob = waste_request_type()
        ob.WASTEREQUEST_id = obj.id
        ob.WASTETYPE_id = id
        ob.collectedqty = "pending"
        ob.baseqty = quantity if quantity != 'pending' else "pending"
        ob.save()
    
    return JsonResponse({"status": "ok", "message": "Waste request submitted successfully"})




def sndpublicoffence(request):
    image = request.FILES['file']
    fs = FileSystemStorage()
    image = fs.save(image.name, image)
    uid = request.POST.get('uid')
    latitude = request.POST.get('latitude', 'pending')
    longitude = request.POST.get('longitude', 'pending')
    
    obj = offence()
    obj.photo = fs.url(image)
    obj.USER_id = uid
    obj.status = "pending"
    obj.date = datetime.datetime.now().date()
    obj.latitude = latitude
    obj.longitude = longitude
    obj.save()
    return JsonResponse({"status": "ok"})

def view_reward(request):
    data=wasterequest.objects.all()
    are=[]
    for i in data:
        are.append({
            'id':i.id,
            'reward':i.reward,
        })


    print(are)

    return JsonResponse({"status": "ok", "data": are})

def logout_view(request):
    logout(request)
    return HttpResponse("<script>alert('Logged out successfully');window.location='/'</script>")

@login_required(login_url='/')
def delete_allocated_area(request, id):
    try:
        allocation = allocatearea.objects.get(id=id)
        allocation.delete()
        return HttpResponse("<script>alert('Allocation deleted successfully');window.location='/allocated_area'</script>")
    except allocatearea.DoesNotExist:
        return HttpResponse("<script>alert('Allocation not found');window.location='/allocated_area'</script>")

def place_order(request):
    """Place order from cart items and convert to credit points
    If cart contains items from multiple recyclers, creates separate orders for each recycler
    """
    try:
        uid = request.POST.get('uid')
        payment_id = request.POST.get('payment_id', 'TEST_PAYMENT_ID')
        total_amount = request.POST.get('total_amount')
        payment_mode = request.POST.get('payment_mode', 'online')
        reward_points_used = int(request.POST.get('reward_points_used', 0))
        discount_amount = float(request.POST.get('discount_amount', 0))

        if not uid:
            return JsonResponse({"status": "error", "message": "Missing user ID"}, status=400)

        user_obj = user.objects.get(id=uid)

        # Validate reward points - prevent fraud
        current_rewards = int(user_obj.rewards) if user_obj.rewards else 0
        if reward_points_used > current_rewards:
            return JsonResponse({
                "status": "error",
                "message": f"Insufficient reward points. Available: {current_rewards}, Requested: {reward_points_used}"
            }, status=400)

        # Validate discount matches reward points (1:1 conversion)
        if abs(discount_amount - reward_points_used) > 0.01:
            return JsonResponse({
                "status": "error",
                "message": "Discount amount does not match reward points"
            }, status=400)

        # Calculate final amount after discount
        try:
            amount_float = float(total_amount) if total_amount else 0
            final_amount = max(0, amount_float - discount_amount)
        except (ValueError, TypeError):
            final_amount = 0

        # Get cart items for this user
        cart_items = cart.objects.filter(USER_id=uid)

        if not cart_items.exists():
            return JsonResponse({"status": "error", "message": "Cart is empty"}, status=400)

        # Group cart items by recycler and calculate actual amounts
        recycler_items = {}
        recycler_totals = {}
        grand_total_cart = 0

        for item in cart_items:
            recycler_id = item.PRODUCT.RECYCLER_id

            # Calculate item total
            item_price = float(item.PRODUCT.price) if item.PRODUCT.price else 0
            item_qty = float(item.qty) if item.qty else 0
            item_total = item_price * item_qty

            if recycler_id not in recycler_items:
                recycler_items[recycler_id] = []
                recycler_totals[recycler_id] = 0

            recycler_items[recycler_id].append(item)
            recycler_totals[recycler_id] += item_total
            grand_total_cart += item_total

        # Calculate proportional discount for each recycler based on their share
        created_orders = []
        total_actual_final_amount = 0  # Total after discount across all recyclers

        for recycler_id, items in recycler_items.items():
            # Calculate this recycler's share of the cart total
            recycler_share = recycler_totals[recycler_id] / grand_total_cart if grand_total_cart > 0 else 0

            # Calculate discount for this recycler proportionally
            recycler_discount = discount_amount * recycler_share

            # Calculate final amount for this recycler after their share of discount
            recycler_final_amount = max(0, recycler_totals[recycler_id] - recycler_discount)
            total_actual_final_amount += recycler_final_amount

            # Create order for this recycler
            order_obj = order()
            order_obj.USER_id = uid
            order_obj.date = datetime.datetime.now().date()
            order_obj.status = "completed"  # Mark as completed after payment
            order_obj.paymentmode = payment_mode
            order_obj.amount = str(recycler_final_amount)  # Store final amount after discount
            order_obj.RECYCLER_id = recycler_id
            order_obj.save()

            created_orders.append({
                'id': order_obj.id,
                'recycler_id': recycler_id,
                'original_amount': recycler_totals[recycler_id],
                'discount': recycler_discount,
                'final_amount': recycler_final_amount,
                'items_count': len(items)
            })

            # Process items for this recycler
            for item in items:
                ordersub_obj = ordersub()
                ordersub_obj.ORDER_id = order_obj.id
                ordersub_obj.PRODUCT_id = item.PRODUCT_id
                ordersub_obj.qty = item.qty
                ordersub_obj.save()

                # Decrease product stock when order is placed
                try:
                    product_obj = product.objects.get(id=item.PRODUCT_id)
                    current_qty = int(product_obj.qty) if product_obj.qty else 0
                    qty_to_subtract = int(item.qty) if item.qty else 0

                    if current_qty >= qty_to_subtract:
                        product_obj.qty = str(current_qty - qty_to_subtract)
                        product_obj.save()
                        print(f"Stock decreased for product {product_obj.name}: {current_qty} -> {product_obj.qty}")
                    else:
                        print(f"Warning: Insufficient stock for product {product_obj.name}")
                        # Optionally, you might want to handle this case
                except product.DoesNotExist:
                    print(f"Warning: Product not found for stock decrease")

        # CORRECTED: Calculate credit points based on FINAL AMOUNT PAID
        # NOT based on the original total_amount, but based on what was actually paid
        # 10% bonus on the actual payment amount
        credit_points = int(final_amount) + int(final_amount * 0.1)  # 10% bonus on paid amount

        # Update user rewards: deduct used points and add earned points
        current_rewards = int(user_obj.rewards) if user_obj.rewards else 0

        # Only deduct if points were actually used
        if reward_points_used > 0:
            current_rewards -= reward_points_used

        # Add credit points earned from this purchase
        new_rewards = current_rewards + credit_points
        user_obj.rewards = max(0, new_rewards)  # Ensure non-negative
        user_obj.save()

        # Clear cart after order
        cart_items.delete()

        # Verify the payment made matches calculated final amount
        payment_verification = abs(float(total_actual_final_amount) - float(final_amount)) < 0.01

        return JsonResponse({
            "status": "ok",
            "message": f"Order{'s' if len(recycler_items) > 1 else ''} placed successfully",
            "orders_created": len(recycler_items),
            "order_ids": [o['id'] for o in created_orders],
            "orders": created_orders,
            "payment_id": payment_id,
            "original_amount": total_amount,
            "total_cart_value": grand_total_cart,
            "discount_applied": discount_amount,
            "final_amount": final_amount,
            "calculated_final_amount": total_actual_final_amount,
            "payment_verified": payment_verification,
            "reward_points_used": reward_points_used,
            "credit_points_earned": credit_points,
            "total_rewards": user_obj.rewards,
            "rewards_before_order": current_rewards + reward_points_used,  # Original points before deduction
        })

    except user.DoesNotExist:
        return JsonResponse({"status": "error", "message": "User not found"}, status=404)
    except Exception as e:
        print(f"Error in place_order: {str(e)}")
        import traceback
        traceback.print_exc()
        return JsonResponse({"status": "error", "message": str(e)}, status=500)

# def place_order(request):
#     """Place order from cart items and convert to credit points
#     If cart contains items from multiple recyclers, creates separate orders for each recycler
#     """
#     try:
#         uid = request.POST.get('uid')
#         payment_id = request.POST.get('payment_id', 'TEST_PAYMENT_ID')
#         total_amount = request.POST.get('total_amount')
#         payment_mode = request.POST.get('payment_mode', 'online')
#         reward_points_used = int(request.POST.get('reward_points_used', 0))
#         discount_amount = float(request.POST.get('discount_amount', 0))
#
#         if not uid:
#             return JsonResponse({"status": "error", "message": "Missing user ID"}, status=400)
#
#         user_obj = user.objects.get(id=uid)
#
#         # Validate reward points - prevent fraud
#         current_rewards = int(user_obj.rewards) if user_obj.rewards else 0
#         if reward_points_used > current_rewards:
#             return JsonResponse({
#                 "status": "error",
#                 "message": f"Insufficient reward points. Available: {current_rewards}, Requested: {reward_points_used}"
#             }, status=400)
#
#         # Validate discount matches reward points (1:1 conversion)
#         if abs(discount_amount - reward_points_used) > 0.01:
#             return JsonResponse({
#                 "status": "error",
#                 "message": "Discount amount does not match reward points"
#             }, status=400)
#
#         # Calculate final amount after discount
#         try:
#             amount_float = float(total_amount) if total_amount else 0
#             final_amount = max(0, amount_float - discount_amount)
#         except (ValueError, TypeError):
#             final_amount = 0
#
#         # Get cart items for this user
#         cart_items = cart.objects.filter(USER_id=uid)
#
#         if not cart_items.exists():
#             return JsonResponse({"status": "error", "message": "Cart is empty"}, status=400)
#
#         # Group cart items by recycler
#         recycler_items = {}
#         for item in cart_items:
#             recycler_id = item.PRODUCT.RECYCLER_id
#             if recycler_id not in recycler_items:
#                 recycler_items[recycler_id] = []
#             recycler_items[recycler_id].append(item)
#
#         # Create orders for each recycler
#         created_orders = []
#         total_reward_points = 0
#         recycler_count = len(recycler_items)
#
#         # Distribute discount proportionally across orders if multiple recyclers
#         discount_per_order = discount_amount / recycler_count if recycler_count > 0 else 0
#         final_amount_per_order = final_amount / recycler_count if recycler_count > 0 else 0
#
#         for recycler_id, items in recycler_items.items():
#             # Create order for this recycler
#             order_obj = order()
#             order_obj.USER_id = uid
#             order_obj.date = datetime.datetime.now().date()
#             order_obj.status = "completed"  # Mark as completed after payment
#             order_obj.paymentmode = payment_mode
#             order_obj.amount = str(final_amount_per_order)  # Store final amount after discount
#             order_obj.RECYCLER_id = recycler_id
#             order_obj.save()
#
#             created_orders.append({
#                 'id': order_obj.id,
#                 'recycler_id': recycler_id,
#                 'amount': final_amount_per_order,
#                 'items_count': len(items)
#             })
#
#             # Process items for this recycler
#             for item in items:
#                 ordersub_obj = ordersub()
#                 ordersub_obj.ORDER_id = order_obj.id
#                 ordersub_obj.PRODUCT_id = item.PRODUCT_id
#                 ordersub_obj.qty = item.qty
#                 ordersub_obj.save()
#
#                 # Decrease product stock when order is placed
#                 try:
#                     product_obj = product.objects.get(id=item.PRODUCT_id)
#                     current_qty = int(product_obj.qty) if product_obj.qty else 0
#                     qty_to_subtract = int(item.qty) if item.qty else 0
#
#                     if current_qty >= qty_to_subtract:
#                         product_obj.qty = str(current_qty - qty_to_subtract)
#                         product_obj.save()
#                         print(f"Stock decreased for product {product_obj.name}: {current_qty} -> {product_obj.qty}")
#                     else:
#                         print(f"Warning: Insufficient stock for product {product_obj.name}")
#                 except product.DoesNotExist:
#                     print(f"Warning: Product not found for stock decrease")
#
#                 # Calculate reward points: 10% of amount per item (1 point per rupee)
#                 item_points = int(float(item.qty) * 0.1) if item.qty else 0
#                 total_reward_points += item_points
#
#         # Convert final amount to credit points (1 rupee = 1 point, 10% bonus for orders)
#         credit_points = int(final_amount) + int(final_amount * 0.1)  # 10% bonus
#
#         # Update user rewards: deduct used points and add earned points
#         current_rewards = int(user_obj.rewards) if user_obj.rewards else 0
#         new_rewards = current_rewards - reward_points_used + credit_points + total_reward_points
#         user_obj.rewards = max(0, new_rewards)  # Ensure non-negative
#         user_obj.save()
#
#         # Clear cart after order
#         cart_items.delete()
#
#         return JsonResponse({
#             "status": "ok",
#             "message": f"Order{'s' if recycler_count > 1 else ''} placed successfully" if recycler_count > 1 else "Order placed successfully",
#             "orders_created": recycler_count,
#             "order_ids": [o['id'] for o in created_orders],
#             "orders": created_orders,
#             "payment_id": payment_id,
#             "original_amount": total_amount,
#             "discount_applied": discount_amount,
#             "final_amount": final_amount,
#             "reward_points_used": reward_points_used,
#             "credit_points_earned": "0",
#             "total_rewards": user_obj.rewards,
#         })
#
#     except user.DoesNotExist:
#         return JsonResponse({"status": "error", "message": "User not found"}, status=404)
#     except Exception as e:
#         return JsonResponse({"status": "error", "message": str(e)}, status=500)


def decrease_stock(request):
    """Decrease product stock after order"""
    try:
        cart_id = request.POST.get('cart_id')
        quantity = request.POST.get('quantity')
        
        if not cart_id or not quantity:
            return JsonResponse({"status": "error", "message": "Missing required fields"}, status=400)
        
        cart_item = cart.objects.get(id=cart_id)
        product_obj = product.objects.get(id=cart_item.PRODUCT_id)
        
        # Decrease product quantity
        current_qty = int(product_obj.qty)
        qty_to_subtract = int(quantity)
        
        if current_qty >= qty_to_subtract:
            product_obj.qty = str(current_qty - qty_to_subtract)
            product_obj.save()
            return JsonResponse({"status": "ok", "message": "Stock decreased successfully"})
        else:
            return JsonResponse({
                "status": "error",
                "message": "Insufficient stock"
            }, status=400)
    
    except cart.DoesNotExist:
        return JsonResponse({"status": "error", "message": "Cart item not found"}, status=404)
    except product.DoesNotExist:
        return JsonResponse({"status": "error", "message": "Product not found"}, status=404)
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)}, status=500)


def delete_cart_item(request):
    """Delete item from cart"""
    try:
        cart_id = request.POST.get('cart_id')
        
        if not cart_id:
            return JsonResponse({"status": "error", "message": "Cart ID required"}, status=400)
        
        cart_item = cart.objects.get(id=cart_id)
        cart_item.delete()
        
        return JsonResponse({"status": "ok", "message": "Item removed from cart"})
    
    except cart.DoesNotExist:
        return JsonResponse({"status": "error", "message": "Cart item not found"}, status=404)
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)}, status=500)


def check_product_stock(request):
    """Check if a product is in stock"""
    try:
        product_id = request.POST.get('product_id')
        
        if not product_id:
            return JsonResponse({"status": "error", "message": "Product ID required"}, status=400)
        
        product_obj = product.objects.get(id=product_id)
        
        # Check if quantity is greater than 0
        qty = int(product_obj.qty) if product_obj.qty else 0
        in_stock = qty > 0
        
        return JsonResponse({
            "status": "ok",
            "in_stock": in_stock,
            "quantity": qty,
        })
    
    except product.DoesNotExist:
        return JsonResponse({"status": "error", "message": "Product not found"}, status=404)
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)}, status=500)


def view_order_details(request):
    """Get detailed order information with items and waste collection details"""
    try:
        order_id = request.POST.get('order_id')
        
        if not order_id:
            return JsonResponse({"status": "error", "message": "Order ID required"}, status=400)
        
        order_obj = order.objects.get(id=order_id)
        items = ordersub.objects.filter(ORDER_id=order_id)
        
        # Build items list with product details
        items_list = []
        total_qty = 0
        
        for item in items:
            product_obj = product.objects.get(id=item.PRODUCT_id)
            item_qty = int(item.qty) if item.qty else 0
            total_qty += item_qty
            
            items_list.append({
                'id': item.id,
                'product_name': product_obj.name,
                'product_id': product_obj.id,
                'quantity': item_qty,
                'price': float(product_obj.price) if product_obj.price else 0,
                'item_total': float(product_obj.price) * item_qty if product_obj.price else 0,
            })
        
        return JsonResponse({
            "status": "ok",
            "order": {
                'id': order_obj.id,
                'date': str(order_obj.date),
                'status': order_obj.status,
                'payment_mode': order_obj.paymentmode,
                'amount': float(order_obj.amount) if order_obj.amount else 0,
                'recycler_name': order_obj.RECYCLER.name if order_obj.RECYCLER else 'Unknown',
                'recycler_contact': order_obj.RECYCLER.phone if order_obj.RECYCLER else 'N/A',
            },
            "items": items_list,
            "total_items": len(items_list),
            "total_quantity": total_qty,
        })
    
    except order.DoesNotExist:
        return JsonResponse({"status": "error", "message": "Order not found"}, status=404)
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)}, status=500)




def forgotemail(request):
    import random
    import smtplib
    email = request.POST['email']
    print(email)
    data = User.objects.filter(username=email)
    print(data)
    if data.exists():
        otp = str(random.randint(000000, 999999))
        print(otp)
        # *✨ Python Email Codeimport smtplib*

        from email.mime.text import MIMEText
        from email.mime.multipart import MIMEMultipart

        # ✅ Gmail credentials (use App Password, not real password)
        try:
            sender_email = "smartfuddonation@gmail.com"
            receiver_email = "receiver_email@gmail.com"  # change to actual recipient
            app_password = "your_16_char_app_password"
            # Setup SMTP
            server = smtplib.SMTP("smtp.gmail.com", 587)
            server.starttls()
            server.login(sender_email, app_password)

            # Create the email
            msg = MIMEMultipart("alternative")
            msg["From"] = sender_email
            msg["To"] = receiver_email
            msg["Subject"] = "🔑 Forgot Password "

            # Plain text (backup)
            # text = f"""
            # Hello,

            # Your password for Smart Donation Website is: {pwd}

            # Please keep it safe and do not share it with anyone.
            # """

            # HTML (attractive)
            html = f"""
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Password Reset OTP</title>
                </head>
                <body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                            line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">

                    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                                padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
                        <h1 style="color: white; margin: 0; font-size: 28px;">
                            🔐 Smart Donation
                        </h1>
                    </div>

                    <div style="background-color: #f9f9f9; padding: 40px 30px; border-radius: 0 0 10px 10px; 
                                border: 1px solid #eaeaea;">

                        <h2 style="color: #2d3748; margin-top: 0;">Password Reset Request</h2>

                        <p style="color: #4a5568; font-size: 16px;">
                            Hello,
                        </p>

                        <p style="color: #4a5568; font-size: 16px;">
                            You requested to reset your password. Use the OTP below to proceed:
                        </p>

                        <div style="background: white; border-radius: 8px; padding: 20px; 
                                    text-align: center; margin: 30px 0; border: 2px dashed #cbd5e0;">
                            <div style="font-size: 32px; font-weight: bold; letter-spacing: 10px; 
                                        color: #2c7be5; margin: 10px 0;">
                                {otp}
                            </div>
                            <div style="font-size: 14px; color: #718096; margin-top: 10px;">
                                (Valid for 10 minutes)
                            </div>
                        </div>

                        <p style="color: #4a5568; font-size: 16px;">
                            Enter this code on the password reset page to complete the process.
                        </p>

                        <div style="background-color: #fef3c7; border-left: 4px solid #d97706; 
                                    padding: 15px; margin: 25px 0; border-radius: 4px;">
                            <p style="color: #92400e; margin: 0; font-size: 14px;">
                                ⚠️ <strong>Security tip:</strong> Never share this OTP with anyone. 
                                Our team will never ask for your password or OTP.
                            </p>
                        </div>

                        <p style="color: #718096; font-size: 14px;">
                            If you didn't request this password reset, please ignore this email or 
                            contact our support team if you have concerns.
                        </p>

                        <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 30px 0;">

                        <p style="text-align: center; color: #a0aec0; font-size: 12px;">
                            This is an automated email from Smart Donation System.<br>
                            © {datetime.now().year} Smart Donation. All rights reserved.
                        </p>

                    </div>
                </body>
                </html>
                """

            # Attach both versions
            # msg.attach(MIMEText(text, "plain"))
            msg.attach(MIMEText(html, "html"))

            # Send email
            server.send_message(msg)
            print("✅ Email sent successfully!", otp)

            # Close connection
            server.quit()

        except Exception as e:
            print("❌ Error loading email credentials:", e)
            return JsonResponse({'status': "ok", 'otpp': otp})

        return JsonResponse({'status': 'ok', 'otpp': otp})
    return JsonResponse({'status': "not found"})


def forgotpass(request):
    email = request.POST['email']
    npass = request.POST['password']
    cpass = request.POST['confirmpassword']
    print(email, npass, cpass)
    if npass == cpass:
        User.objects.filter(username=email).update(password=make_password(npass))
        return JsonResponse({'status': 'ok'})
    return JsonResponse({'status': 'invalid'})




def changepassword_user(request):
    current_password=request.POST["current"]
    new_password=request.POST["neww"]
    confirm_password=request.POST["confirm"]
    passw=request.POST["passw"]
    uid=request.POST["uid"]
    print(current_password,new_password,confirm_password,uid,passw)
    if passw == current_password:
        if new_password == confirm_password:
            obj=user.objects.get(id=uid).LOGIN_id
            print(obj)
            User.objects.filter(id=obj).update(password = make_password(new_password))
            return JsonResponse({'status': 'ok'},status=200)
        return JsonResponse({'status': 'invalid'},status=500)
    return JsonResponse({'status':'invalid'},status=500)

