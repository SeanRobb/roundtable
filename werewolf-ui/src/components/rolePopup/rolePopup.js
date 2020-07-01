import React from 'react';
import PropTypes from 'prop-types';
import styles from './rolePopup.module.css';
import Modal from '@material-ui/core/Modal';
import Dialog from '@material-ui/core/Dialog';
import Box from '@material-ui/core/Box';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogContentText from '@material-ui/core/DialogContentText';

const RolePopup = (props) => (
<Dialog className={styles.rolePopup} data-testid="rolePopup"
  open={props.open}
  onClose={props.onClose}
>
  <Box className='popup\_inner'>  
    <DialogTitle>
      {props.role.name}
    </DialogTitle>
    <DialogContentText>{props.role.description}</DialogContentText>
  </Box>  
</Dialog>
);

RolePopup.propTypes = {};

RolePopup.defaultProps = {};

export default RolePopup;
