import React from 'react';
import PropTypes from 'prop-types';
import styles from './votePopup.module.css';
import Dialog from '@material-ui/core/Dialog';
import ButtonGroup from '@material-ui/core/ButtonGroup';
import Button from '@material-ui/core/Button';
import Box from '@material-ui/core/Box';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogContentText from '@material-ui/core/DialogContentText';

const VotePopup = (props) => (
  <Dialog className={styles.rolePopup} data-testid="rolePopup"
  open={props.open}
  onClose={props.onClose}
>
  <Box className='popup\_inner'>  
    <DialogTitle>
      Vote
    </DialogTitle>
    <ButtonGroup
        style={{padding:"15px"}}
        orientation="vertical"
        color="primary"
        aria-label="vertical outlined primary button group"
      >
        {props.ballot.map((person) => <Button key={person} onClick={()=>props.onVote(person)}>{person}</Button>)}
      </ButtonGroup>
  </Box>  
</Dialog>
);

VotePopup.propTypes = {};

VotePopup.defaultProps = {};

export default VotePopup;
