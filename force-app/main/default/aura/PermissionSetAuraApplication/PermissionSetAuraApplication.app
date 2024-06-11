<aura:application extends="force:slds" access="GLOBAL">
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
    <div class="my-app-background">
        <!-- Your Aura component content goes here -->
        <c:permissionSetAppHeader></c:permissionSetAppHeader>
    </div>
</aura:application>