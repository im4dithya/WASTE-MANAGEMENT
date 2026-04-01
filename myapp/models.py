from django.contrib.auth.models import User
from django.db import models

# Create your models here.
class area(models.Model):
    district=models.CharField(max_length=100)
    panchayath=models.CharField(max_length=100)
    latitude=models.CharField(max_length=100)
    longitude=models.CharField(max_length=100)


class user(models.Model):
    AREA=models.ForeignKey(area,on_delete=models.CASCADE)
    name=models.CharField(max_length=100)
    email=models.CharField(max_length=100)
    phone=models.CharField(max_length=100)
    housename=models.CharField(max_length=100)
    post=models.CharField(max_length=100)
    pin=models.CharField(max_length=100)
    LOGIN=models.ForeignKey(User,on_delete=models.CASCADE)
    latitude=models.CharField(max_length=100)
    longitude=models.CharField(max_length=100)
    rewards=models.IntegerField(default=0)

class waste_type(models.Model):
    waste=models.CharField(max_length=100)
    amount=models.CharField(max_length=100)
    note=models.CharField(max_length=100)
    reward=models.CharField(max_length=100)

class pickup_recycler(models.Model):
    name=models.CharField(max_length=100)
    email=models.CharField(max_length=100)
    phone=models.CharField(max_length=100)
    photo=models.CharField(max_length=100)
    proof=models.CharField(max_length=100)
    status=models.CharField(max_length=100)
    LOGIN=models.ForeignKey(User,on_delete=models.CASCADE)
    type=models.CharField(max_length=100)

class offence(models.Model):
    USER=models.ForeignKey(user,on_delete=models.CASCADE)
    photo=models.CharField(max_length=100)
    date=models.CharField(max_length=100)
    status=models.CharField(max_length=100)
    latitude=models.CharField(max_length=100)
    longitude=models.CharField(max_length=100)

class allocatearea(models.Model):
    AREA=models.ForeignKey(area,on_delete=models.CASCADE)
    PICKUP=models.ForeignKey(pickup_recycler,on_delete=models.CASCADE)
    date=models.CharField(max_length=100)

class complaint(models.Model):
    complaint=models.CharField(max_length=100)
    complaintdate=models.CharField(max_length=100)
    reply=models.CharField(max_length=100)
    replydate=models.CharField(max_length=100)
    USER=models.ForeignKey(user,on_delete=models.CASCADE)

class feedback(models.Model):
    USER=models.ForeignKey(user,on_delete=models.CASCADE)
    feedback=models.CharField(max_length=100)
    date=models.CharField(max_length=100)

class product(models.Model):
    RECYCLER=models.ForeignKey(pickup_recycler,on_delete=models.CASCADE)
    name=models.CharField(max_length=100)
    photo=models.CharField(max_length=100)
    price=models.CharField(max_length=100)
    qty=models.CharField(max_length=100)

class cart(models.Model):
    USER= models.ForeignKey(user, on_delete=models.CASCADE)
    PRODUCT= models.ForeignKey(product,on_delete=models.CASCADE)
    qty = models.CharField(max_length=100)

class order(models.Model):
    USER= models.ForeignKey(user, on_delete=models.CASCADE)
    date = models.CharField(max_length=100)
    status = models.CharField(max_length=100)
    RECYCLER= models.ForeignKey(pickup_recycler,on_delete=models.CASCADE)
    paymentmode= models.CharField(max_length=100)
    amount=models.CharField(max_length=100)

class ordersub(models.Model):
    ORDER= models.ForeignKey(order, on_delete=models.CASCADE)
    PRODUCT = models.ForeignKey(product,on_delete=models.CASCADE)
    qty= models.CharField(max_length=100)


class wastecart(models.Model):
    USER= models.ForeignKey(user, on_delete=models.CASCADE)
    WASTETYPE= models.ForeignKey(waste_type,on_delete=models.CASCADE)
    baseqty = models.CharField(max_length=100)


class wasterequest(models.Model):
    USER= models.ForeignKey(user, on_delete=models.CASCADE)
    amount= models.CharField(max_length=100)
    collectiondate= models.CharField(max_length=100)
    status= models.CharField(max_length=100)
    requesteddate= models.CharField(max_length=100)
    reward= models.CharField(max_length=100)


class waste_request_type(models.Model):
    WASTEREQUEST=models.ForeignKey(wasterequest,on_delete=models.CASCADE)
    WASTETYPE=models.ForeignKey(waste_type,on_delete=models.CASCADE)
    collectedqty=models.CharField(max_length=100)
    baseqty=models.CharField(max_length=100)

# class Reward(models.Model):
#     WASTEREQUEST=models.ForeignKey(wasterequest,on_delete=models.CASCADE)
#     reward=models.CharField(max_length=100)
#     RECYCLER=models.ForeignKey(pickup_recycler,on_delete=models.CASCADE)




