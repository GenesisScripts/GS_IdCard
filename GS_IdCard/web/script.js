function showBadge(data) {
    document.body.style.display = 'inline';
    document.getElementById('name').innerText = `${data.name}`;
    document.getElementById('rank').innerText = `${data.dob}`;
    document.getElementById('license_expired').innerText = `${data.license_expired}`;
    document.getElementById('address').innerText = `${data.address}`;

    // Join all license types into a single string, separated by commas
    let licenseTypes = data.license_types ? data.license_types.join(', ') : 'No Licenses';
    document.getElementById('license_type').innerText = `${licenseTypes}`;
    
    if (data.photo) {
        document.getElementById('background-img').src = data.photo;
    }

    // Hide the badge after 5 seconds
    setTimeout(() => {
        document.body.style.display = 'none';
    }, 5000);
}

window.addEventListener('message', function(event) {
    if (event.data && event.data.type === "displayBadge" && event.data.data) {
        showBadge(event.data.data);
    }
});
